import axios from "axios";

export interface WeatherData {
  et0: number;       // Reference evapotranspiration (mm/day)
  rainfall: number;  // Precipitation corrected (mm/day)
  maxTempC: number;  // Max 2m temperature (°C)
  minTempC: number;  // Min 2m temperature (°C)
  humidityPct: number; // Relative humidity at 2m (%)
}

const BASE_URL = "https://power.larc.nasa.gov/api/temporal/daily/point";

/** Fetches yesterday's actuals + today's estimate from NASA POWER (free, no API key). */
export async function fetchWeather(
  lat: number,
  lon: number,
  date: Date,
): Promise<WeatherData> {
  const end = toNasaDate(date);
  const start = toNasaDate(new Date(date.getTime() - 86_400_000)); // yesterday

  const { data } = await axios.get(BASE_URL, {
    params: {
      parameters: "ET0,PRECTOTCORR,T2M_MAX,T2M_MIN,RH2M",
      community: "AG",
      longitude: lon.toFixed(4),
      latitude: lat.toFixed(4),
      start,
      end,
      format: "JSON",
    },
    timeout: 20_000,
  });

  const p = data.properties.parameter;

  return {
    et0:          safeAvg(Object.values<number>(p.ET0)),
    rainfall:     safeAvg(Object.values<number>(p.PRECTOTCORR)),
    maxTempC:     safeAvg(Object.values<number>(p.T2M_MAX)),
    minTempC:     safeAvg(Object.values<number>(p.T2M_MIN)),
    humidityPct:  safeAvg(Object.values<number>(p.RH2M)),
  };
}

function toNasaDate(d: Date): string {
  return d.toISOString().slice(0, 10).replace(/-/g, "");
}

// NASA POWER uses -999 for missing values
function safeAvg(values: number[]): number {
  const valid = values.filter((v) => v > -900);
  if (valid.length === 0) return 0;
  return valid.reduce((a, b) => a + b, 0) / valid.length;
}
