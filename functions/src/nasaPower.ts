import axios from "axios";

export interface WeatherData {
  et0: number;         // Reference evapotranspiration (mm/day)
  rainfall: number;    // Precipitation corrected (mm/day)
  maxTempC: number;    // Max 2m temperature (°C)
  minTempC: number;    // Min 2m temperature (°C)
  humidityPct: number; // Relative humidity at 2m (%)
}

const BASE_URL = "https://power.larc.nasa.gov/api/temporal/daily/point";
const MAX_RETRIES = 3;

/**
 * Fetches yesterday's actuals + today's estimate from NASA POWER (free, no API key).
 * Retries up to 3 times with exponential backoff on transient failures.
 */
export async function fetchWeather(
  lat: number,
  lon: number,
  date: Date,
): Promise<WeatherData> {
  let lastError: unknown;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      return await _fetchOnce(lat, lon, date);
    } catch (err) {
      lastError = err;
      if (attempt < MAX_RETRIES) {
        const delayMs = attempt * 1_500; // 1.5s → 3s backoff
        console.warn(`[NASA POWER] Attempt ${attempt} failed, retrying in ${delayMs}ms:`, err);
        await new Promise((r) => setTimeout(r, delayMs));
      }
    }
  }

  throw lastError;
}

async function _fetchOnce(lat: number, lon: number, date: Date): Promise<WeatherData> {
  const end   = toNasaDate(date);
  const start = toNasaDate(new Date(date.getTime() - 86_400_000));

  const { data } = await axios.get(BASE_URL, {
    params: {
      parameters: "ET0,PRECTOTCORR,T2M_MAX,T2M_MIN,RH2M",
      community: "AG",
      longitude: lon.toFixed(4),
      latitude:  lat.toFixed(4),
      start,
      end,
      format: "JSON",
    },
    timeout: 20_000,
  });

  const p = data.properties.parameter;

  return {
    et0:         safeAvg(Object.values<number>(p.ET0)),
    rainfall:    safeAvg(Object.values<number>(p.PRECTOTCORR)),
    maxTempC:    safeAvg(Object.values<number>(p.T2M_MAX)),
    minTempC:    safeAvg(Object.values<number>(p.T2M_MIN)),
    humidityPct: safeAvg(Object.values<number>(p.RH2M)),
  };
}

function toNasaDate(d: Date): string {
  return d.toISOString().slice(0, 10).replace(/-/g, "");
}

// NASA POWER uses -999 for missing data points
function safeAvg(values: number[]): number {
  const valid = values.filter((v) => v > -900);
  if (valid.length === 0) return 0;
  return valid.reduce((a, b) => a + b, 0) / valid.length;
}
