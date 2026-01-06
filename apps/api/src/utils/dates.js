import { DateTime } from "luxon";

export function startOfDayISO(timezone, isoDate) {
  const base = isoDate ? DateTime.fromISO(isoDate) : DateTime.now();
  return base.setZone(timezone).startOf("day").toUTC().toISO();
}

export function endOfDayISO(timezone, isoDate) {
  const base = isoDate ? DateTime.fromISO(isoDate) : DateTime.now();
  return base.setZone(timezone).endOf("day").toUTC().toISO();
}

export function toDayKey(timezone, isoDate) {
  const base = isoDate ? DateTime.fromISO(isoDate) : DateTime.now();
  return base.setZone(timezone).toFormat("yyyy-LL-dd");
}
