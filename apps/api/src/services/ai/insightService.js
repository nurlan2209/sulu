import mongoose from "mongoose";
import { DateTime } from "luxon";
import { ApiError } from "../../errors/ApiError.js";
import { AIInsightModel } from "../../models/AIInsight.js";
import { UserModel } from "../../models/User.js";
import { WaterLogModel } from "../../models/WaterLog.js";
import { toDayKey } from "../../utils/dates.js";
import { createAIProvider } from "./providers.js";

function clampDays(period) {
  return period === "daily" ? 14 : 30;
}

export async function getOrCreateInsight(env, input) {
  const now = input.now ?? new Date();

  const user = await UserModel.findById(input.userId).lean().exec();
  if (!user) throw new ApiError(404, "not_found", "User not found");
  const timezone = user.timezone ?? env.CRON_TIMEZONE;
  const dayKey = toDayKey(timezone, now.toISOString());

  const existing = await AIInsightModel.findOne({ userId: user._id, period: input.period, dayKey }).lean().exec();
  if (existing) return existing;

  const days = clampDays(input.period);
  const from = DateTime.fromJSDate(now).setZone(timezone).minus({ days }).toUTC().toJSDate();
  const logs = await WaterLogModel.find({ userId: user._id, createdAt: { $gte: from, $lte: now } })
    .sort({ createdAt: 1 })
    .lean()
    .exec();

  const total = logs.reduce((sum, l) => sum + (l.amount ?? 0), 0);
  const avgPerDay = Math.round(total / Math.max(1, days));

  const payload = {
    profile: { weight: user.weight, dailyWaterGoal: user.dailyWaterGoal, streak: user.streak },
    windowDays: days,
    totals: { totalMl: total, avgMlPerDay: avgPerDay },
    samples: logs.slice(-120).map((l) => ({ amount: l.amount, at: l.createdAt }))
  };

  const provider = createAIProvider(env);
  const text = await provider.generateInsight({ language: user.language, payload, period: input.period });

  const created = await AIInsightModel.create({
    userId: new mongoose.Types.ObjectId(input.userId),
    period: input.period,
    dayKey,
    text,
    createdAt: now
  });

  return created.toObject();
}

export async function listInsights(userId, period, limit = 14) {
  const userObjectId = new mongoose.Types.ObjectId(userId);
  return AIInsightModel.find({ userId: userObjectId, period }).sort({ createdAt: -1 }).limit(limit).lean().exec();
}
