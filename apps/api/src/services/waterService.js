import mongoose from "mongoose";
import { DateTime } from "luxon";
import { ApiError } from "../errors/ApiError.js";
import { UserModel } from "../models/User.js";
import { WaterLogModel } from "../models/WaterLog.js";
import { endOfDayISO, startOfDayISO } from "../utils/dates.js";

export async function addWaterLog(input) {
  const userObjectId = new mongoose.Types.ObjectId(input.userId);
  await WaterLogModel.create({
    userId: userObjectId,
    amount: input.amount,
    temperature: input.temperature ?? undefined
  });
  return getTodayProgress({ userId: input.userId, timezone: input.timezone });
}

export async function getTodayProgress(input) {
  const user = await UserModel.findById(input.userId).exec();
  if (!user) throw new ApiError(404, "not_found", "User not found");

  const from = startOfDayISO(input.timezone);
  const to = endOfDayISO(input.timezone);
  const logs = await WaterLogModel.find({ userId: user._id, createdAt: { $gte: new Date(from), $lte: new Date(to) } })
    .sort({ createdAt: 1 })
    .lean()
    .exec();
  const consumed = logs.reduce((sum, log) => sum + log.amount, 0);
  const goal = user.dailyWaterGoal ?? 0;
  const percent = goal > 0 ? Math.min(100, Math.round((consumed / goal) * 100)) : 0;
  const items = logs.map((log) => ({
    time: DateTime.fromJSDate(log.createdAt).setZone(input.timezone).toFormat("HH:mm"),
    amount: log.amount
  }));
  return { consumed, goal, percent, logs: items };
}

export async function getDailyTotals(input) {
  const userObjectId = new mongoose.Types.ObjectId(input.userId);
  return WaterLogModel.aggregate([
    { $match: { userId: userObjectId, createdAt: { $gte: new Date(input.fromISO), $lte: new Date(input.toISO) } } },
    {
      $group: {
        _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt", timezone: input.timezone } },
        total: { $sum: "$amount" },
        count: { $sum: 1 }
      }
    },
    { $project: { _id: 0, dayKey: "$_id", total: 1, count: 1 } },
    { $sort: { dayKey: 1 } }
  ]);
}

export async function getStats(input) {
  const user = await UserModel.findById(input.userId).lean().exec();
  if (!user) throw new ApiError(404, "not_found", "User not found");

  const now = input.nowISO ? DateTime.fromISO(input.nowISO) : DateTime.now();
  const local = now.setZone(input.timezone);
  const days = input.period === "day" ? 1 : input.period === "week" ? 7 : 30;
  const from = local.startOf("day").minus({ days: days - 1 }).toUTC().toISO();
  const to = local.endOf("day").toUTC().toISO();

  const daily = await getDailyTotals({ userId: input.userId, fromISO: from, toISO: to, timezone: input.timezone });
  const totals = daily.reduce((sum, d) => sum + d.total, 0);
  const counts = daily.reduce((sum, d) => sum + d.count, 0);
  const avgMlPerDay = Math.round(totals / days);
  const goal = user.dailyWaterGoal ?? 0;
  const avgPercent = goal > 0 ? Math.round((avgMlPerDay / goal) * 100) : 0;
  const avgDrinksPerDay = Number((counts / days).toFixed(1));

  return {
    period: input.period,
    days,
    goal,
    avgMlPerDay,
    avgPercent: Math.max(0, Math.min(100, avgPercent)),
    avgDrinksPerDay,
    daily
  };
}
