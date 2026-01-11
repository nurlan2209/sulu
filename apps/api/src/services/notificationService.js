import { DateTime } from "luxon";
import { ApiError } from "../errors/ApiError.js";
import { UserModel } from "../models/User.js";
import { WaterLogModel } from "../models/WaterLog.js";

const MAX_ITEMS = 64;
const HORIZON_HOURS = 24;

export async function getNotificationRecommendations(input) {
  const user = await UserModel.findById(input.userId).lean().exec();
  if (!user) throw new ApiError(404, "not_found", "User not found");
  if (!user.notificationSettings?.enabled) return { enabled: false, items: [] };

  const tz = input.timezone;
  const localNow = input.nowISO ? DateTime.fromISO(input.nowISO).setZone(tz) : DateTime.now().setZone(tz);

  const quiet = user.notificationSettings.quietHours;
  const [qsH, qsM] = quiet.start.split(":").map((s) => Number(s));
  const [qeH, qeM] = quiet.end.split(":").map((s) => Number(s));

  const interval = user.notificationSettings.intervalMinutes;
  const lastLog = await WaterLogModel.findOne({ userId: user._id }).sort({ createdAt: -1 }).lean().exec();
  const lastLocal = lastLog ? DateTime.fromJSDate(lastLog.createdAt).setZone(tz) : localNow;
  let nextTime = lastLocal.plus({ minutes: interval });
  const soonest = localNow.plus({ minutes: 1 });
  if (nextTime < soonest) nextTime = soonest;

  const items = [];
  const horizon = localNow.plus({ hours: HORIZON_HOURS });
  while (items.length < MAX_ITEMS && nextTime <= horizon) {
    nextTime = moveOutOfQuiet(nextTime, qsH, qsM, qeH, qeM);
    if (nextTime > horizon) break;
    items.push({ type: "long_time_no_drink", fireAt: nextTime.toUTC().toISO() });
    nextTime = nextTime.plus({ minutes: interval });
  }

  return { enabled: true, intervalMinutes: interval, items };
}

function moveOutOfQuiet(time, qsH, qsM, qeH, qeM) {
  const quietStart = time.set({ hour: qsH, minute: qsM, second: 0, millisecond: 0 });
  const quietEnd = time.set({ hour: qeH, minute: qeM, second: 0, millisecond: 0 });
  const crossesMidnight = quietStart > quietEnd;
  const inQuiet = crossesMidnight
    ? time >= quietStart || time <= quietEnd
    : time >= quietStart && time <= quietEnd;
  if (!inQuiet) return time;
  if (!crossesMidnight) return quietEnd;
  if (time >= quietStart) return time.plus({ days: 1 }).set({ hour: qeH, minute: qeM, second: 0, millisecond: 0 });
  return quietEnd;
}
