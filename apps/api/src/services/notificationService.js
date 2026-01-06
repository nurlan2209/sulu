import { DateTime } from "luxon";
import { ApiError } from "../errors/ApiError.js";
import { UserModel } from "../models/User.js";
import { WaterLogModel } from "../models/WaterLog.js";
import { endOfDayISO, startOfDayISO } from "../utils/dates.js";

export async function getNotificationRecommendations(input) {
  const user = await UserModel.findById(input.userId).lean().exec();
  if (!user) throw new ApiError(404, "not_found", "User not found");
  if (!user.notificationSettings?.enabled) return { enabled: false, items: [] };

  const now = input.nowISO ? new Date(input.nowISO) : new Date();
  const tz = input.timezone;
  const localNow = DateTime.fromJSDate(now).setZone(tz);

  const quiet = user.notificationSettings.quietHours;
  const [qsH, qsM] = quiet.start.split(":").map((s) => Number(s));
  const [qeH, qeM] = quiet.end.split(":").map((s) => Number(s));
  const quietStart = localNow.set({ hour: qsH, minute: qsM, second: 0, millisecond: 0 });
  const quietEnd = localNow.set({ hour: qeH, minute: qeM, second: 0, millisecond: 0 });
  const inQuiet = quietStart <= quietEnd ? localNow >= quietStart && localNow <= quietEnd : localNow >= quietStart || localNow <= quietEnd;
  if (inQuiet) return { enabled: true, intervalMinutes: user.notificationSettings.intervalMinutes, items: [] };

  const from = startOfDayISO(input.timezone);
  const to = endOfDayISO(input.timezone);

  const [lastLog] = await WaterLogModel.find({ userId: user._id, createdAt: { $gte: new Date(from), $lte: new Date(to) } })
    .sort({ createdAt: -1 })
    .limit(1)
    .lean()
    .exec();

  const consumedAgg = await WaterLogModel.aggregate([
    { $match: { userId: user._id, createdAt: { $gte: new Date(from), $lte: now } } },
    { $group: { _id: null, total: { $sum: "$amount" } } }
  ]);
  const consumed = consumedAgg[0]?.total ?? 0;

  const minutesSinceLast = lastLog ? Math.round((now.getTime() - new Date(lastLog.createdAt).getTime()) / 60000) : null;
  const interval = user.notificationSettings.intervalMinutes;
  const goal = user.dailyWaterGoal ?? 0;
  const percent = goal > 0 ? consumed / goal : 0;

  const items = [];
  if (!lastLog || (minutesSinceLast !== null && minutesSinceLast >= interval)) {
    items.push({ type: "long_time_no_drink", fireAt: new Date(now.getTime() + 60000).toISOString() });
  }

  const dayStart = new Date(from);
  const dayEnd = new Date(to);
  const dayProgress = (now.getTime() - dayStart.getTime()) / (dayEnd.getTime() - dayStart.getTime());
  if (dayProgress > 0.1 && percent + 0.05 < dayProgress) {
    items.push({ type: "behind_schedule", fireAt: new Date(now.getTime() + 120000).toISOString() });
  }

  return { enabled: true, intervalMinutes: interval, items };
}
