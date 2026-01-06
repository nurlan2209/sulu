import { Router } from "express";
import { DateTime } from "luxon";
import { ApiError } from "../errors/ApiError.js";
import { requireAuth } from "../middleware/requireAuth.js";
import { UserModel } from "../models/User.js";
import { getDailyTotals, getStats } from "../services/waterService.js";

function toDailyStatItems(stats) {
  const goal = stats.goal ?? 0;
  return (stats.daily ?? []).map((d) => ({
    date: d.dayKey,
    totalIntake: d.total,
    goal,
    progress: goal > 0 ? Number((d.total / goal).toFixed(2)) : 0,
    drinkCount: d.count
  }));
}

export function statsRoutes(env) {
  const r = Router();
  r.use(requireAuth(env));

  r.get("/weekly", async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const stats = await getStats({ userId: req.auth.userId, timezone, period: "week" });
      return res.json({ ...stats, items: toDailyStatItems(stats) });
    } catch (e) {
      return next(e);
    }
  });

  r.get("/monthly", async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const monthKey = typeof req.query.month === "string" ? req.query.month : undefined;
      if (monthKey) {
        const month = DateTime.fromFormat(monthKey, "yyyy-MM", { zone: timezone });
        if (!month.isValid) throw new ApiError(400, "bad_request", "Invalid month format, expected YYYY-MM");
        const from = month.startOf("month").startOf("day").toUTC().toISO();
        const to = month.endOf("month").endOf("day").toUTC().toISO();
        const daily = await getDailyTotals({ userId: req.auth.userId, fromISO: from, toISO: to, timezone });
        const totals = daily.reduce((sum, d) => sum + d.total, 0);
        const counts = daily.reduce((sum, d) => sum + d.count, 0);
        const days = month.daysInMonth;
        const avgMlPerDay = Math.round(totals / days);
        const goal = user.dailyWaterGoal ?? 0;
        const avgPercent = goal > 0 ? Math.round((avgMlPerDay / goal) * 100) : 0;
        const avgDrinksPerDay = Number((counts / days).toFixed(1));
        const stats = {
          period: "month",
          days,
          goal,
          avgMlPerDay,
          avgPercent: Math.max(0, Math.min(100, avgPercent)),
          avgDrinksPerDay,
          daily
        };
        return res.json({ ...stats, items: toDailyStatItems(stats) });
      }

      const stats = await getStats({ userId: req.auth.userId, timezone, period: "month" });
      return res.json({ ...stats, items: toDailyStatItems(stats) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
