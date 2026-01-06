import mongoose from "mongoose";
import { BadgeModel } from "../models/Badge.js";
import { UserModel } from "../models/User.js";
import { WaterLogModel } from "../models/WaterLog.js";
import { endOfDayISO, startOfDayISO } from "../utils/dates.js";

export async function applyDailyStreakAndBadges(input) {
  const from = startOfDayISO(input.timezone, input.dayISO);
  const to = endOfDayISO(input.timezone, input.dayISO);

  const users = await UserModel.find({}).exec();
  for (const user of users) {
    const agg = await WaterLogModel.aggregate([
      { $match: { userId: user._id, createdAt: { $gte: new Date(from), $lte: new Date(to) } } },
      { $group: { _id: null, total: { $sum: "$amount" } } }
    ]);
    const consumed = agg[0]?.total ?? 0;
    const goal = user.dailyWaterGoal ?? 0;
    const met = goal > 0 && consumed >= goal;

    if (met) {
      user.streak = (user.streak ?? 0) + 1;
      await BadgeModel.create({ userId: user._id, type: "100_percent_day", earnedAt: new Date(to) }).catch(() => null);
      if (user.streak === 3) {
        await BadgeModel.create({ userId: user._id, type: "3_days_streak", earnedAt: new Date(to) }).catch(() => null);
      }
    } else {
      user.streak = 0;
    }
    await user.save();
  }
}

export async function listBadges(userId) {
  const userObjectId = new mongoose.Types.ObjectId(userId);
  return BadgeModel.find({ userId: userObjectId }).sort({ earnedAt: -1 }).lean().exec();
}
