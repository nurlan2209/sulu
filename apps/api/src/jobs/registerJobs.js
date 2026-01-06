import cron from "node-cron";
import { DateTime } from "luxon";
import { UserModel } from "../models/User.js";
import { WaterLogModel } from "../models/WaterLog.js";
import { getOrCreateInsight } from "../services/ai/insightService.js";
import { applyDailyStreakAndBadges } from "../services/gamificationService.js";

export function registerJobs(env) {
  cron.schedule(
    "1 0 * * *",
    async () => {
      const localNow = DateTime.now().setZone(env.CRON_TIMEZONE);
      const yesterday = localNow.minus({ days: 1 }).toISO();
      await applyDailyStreakAndBadges({ timezone: env.CRON_TIMEZONE, dayISO: yesterday });
    },
    { timezone: env.CRON_TIMEZONE }
  );

  cron.schedule(
    "10 0 * * *",
    async () => {
      if (env.AI_PROVIDER === "disabled") return;
      const since = DateTime.now().setZone(env.CRON_TIMEZONE).minus({ days: 7 }).toUTC().toJSDate();
      const activeUserIds = await WaterLogModel.distinct("userId", { createdAt: { $gte: since } });
      for (const userId of activeUserIds) {
        try {
          await getOrCreateInsight(env, { userId: String(userId), period: "daily" });
        } catch {
          // best-effort
        }
      }
    },
    { timezone: env.CRON_TIMEZONE }
  );

  cron.schedule(
    "20 0 * * 1",
    async () => {
      if (env.AI_PROVIDER === "disabled") return;
      const users = await UserModel.find({}).select({ _id: 1 }).lean().exec();
      for (const u of users) {
        try {
          await getOrCreateInsight(env, { userId: String(u._id), period: "weekly" });
        } catch {
          // best-effort
        }
      }
    },
    { timezone: env.CRON_TIMEZONE }
  );
}
