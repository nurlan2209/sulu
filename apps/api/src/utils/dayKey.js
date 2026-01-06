export function addDaysUTC(d, deltaDays) {
  const next = new Date(d);
  next.setUTCDate(next.getUTCDate() + deltaDays);
  return next;
}
