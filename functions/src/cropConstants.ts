export type CropType =
  | "tomato" | "potato" | "eggplant" | "pepper"
  | "watermelon" | "cantaloupe" | "honeydew"
  | "cucumber" | "squash" | "zucchini";

export const ALL_CROPS: CropType[] = [
  "tomato", "potato", "eggplant", "pepper",
  "watermelon", "cantaloupe", "honeydew",
  "cucumber", "squash", "zucchini",
];

// FAO-56 crop coefficients [initial, development, mid-season, late]
export const KC: Record<CropType, [number, number, number, number]> = {
  tomato:     [0.60, 0.75, 1.15, 0.80],
  potato:     [0.50, 0.75, 1.15, 0.75],
  eggplant:   [0.50, 0.75, 1.15, 0.80],
  pepper:     [0.60, 0.75, 1.15, 0.80],
  watermelon: [0.40, 0.75, 1.00, 0.75],
  cantaloupe: [0.40, 0.75, 1.00, 0.75],
  honeydew:   [0.40, 0.75, 1.00, 0.75],
  cucumber:   [0.60, 0.75, 1.00, 0.75],
  squash:     [0.50, 0.75, 1.00, 0.75],
  zucchini:   [0.50, 0.75, 1.00, 0.75],
};

// FAO-56 stage durations in days [initial, development, mid-season, late]
export const STAGE_DAYS: Record<CropType, [number, number, number, number]> = {
  tomato:     [25, 40, 50, 30],
  potato:     [25, 30, 45, 30],
  eggplant:   [30, 40, 50, 30],
  pepper:     [25, 35, 60, 30],
  watermelon: [20, 30, 50, 30],
  cantaloupe: [20, 30, 50, 30],
  honeydew:   [20, 30, 50, 30],
  cucumber:   [20, 30, 40, 15],
  squash:     [20, 30, 40, 15],
  zucchini:   [20, 30, 40, 15],
};

export const CROP_NAME_AR: Record<CropType, string> = {
  tomato: "طماطم", potato: "بطاطس", eggplant: "باذنجان",
  pepper: "فلفل", watermelon: "بطيخ", cantaloupe: "شمام",
  honeydew: "كنتالوب", cucumber: "خيار", squash: "كوسة", zucchini: "قرع",
};

export function getKc(crop: CropType, daysSincePlanting: number): number {
  const durations = STAGE_DAYS[crop];
  const kcs = KC[crop];
  let accumulated = 0;
  for (let i = 0; i < 4; i++) {
    accumulated += durations[i];
    if (daysSincePlanting < accumulated) return kcs[i];
  }
  return kcs[3]; // past end of cycle, use late-stage Kc
}

export function isFertilizationDay(
  crop: CropType,
  daysSincePlanting: number,
): "base" | "nitrogen" | "potassium" | null {
  const [d0, d1] = STAGE_DAYS[crop];
  if (daysSincePlanting === 0) return "base";
  if (daysSincePlanting === d0) return "nitrogen";
  if (daysSincePlanting === d0 + d1) return "potassium";
  return null;
}
