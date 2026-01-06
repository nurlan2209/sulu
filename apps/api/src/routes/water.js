import { Router } from "express";
import { z } from "zod";
import { ApiError } from "../errors/ApiError.js";
import { requireAuth } from "../middleware/requireAuth.js";
import { validate } from "../middleware/validate.js";
import { UserModel } from "../models/User.js";
import { addWaterLog, getDailyTotals, getStats, getTodayProgress } from "../services/waterService.js";

const addSchema = z.object({
  amount: z.number().int().min(10).max(2000),
  temperature: z.number().min(0).max(100).optional().nullable()
});

const rangeSchema = z.object({
  fromISO: z.string().min(10),
  toISO: z.string().min(10)
});

const statsSchema = z.object({
  period: z.enum(["day", "week", "month"]).optional()
});

export function waterRoutes(env) {
  const r = Router();
  r.use(requireAuth(env));

  r.get("/today", async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const progress = await getTodayProgress({ userId: req.auth.userId, timezone });
      return res.json(progress);
    } catch (e) {
      return next(e);
    }
  });

  r.post("/logs", validate("body", addSchema), async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const progress = await addWaterLog({ userId: req.auth.userId, amount: req.body.amount, temperature: req.body.temperature, timezone });
      return res.status(201).json(progress);
    } catch (e) {
      return next(e);
    }
  });

  // Alias for product spec
  r.post("/add", validate("body", addSchema), async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const progress = await addWaterLog({ userId: req.auth.userId, amount: req.body.amount, temperature: req.body.temperature, timezone });
      return res.status(201).json(progress);
    } catch (e) {
      return next(e);
    }
  });

  r.get("/daily", validate("query", rangeSchema), async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const days = await getDailyTotals({ userId: req.auth.userId, fromISO: req.query.fromISO, toISO: req.query.toISO, timezone });
      return res.json({ days });
    } catch (e) {
      return next(e);
    }
  });

  r.get("/stats", validate("query", statsSchema), async (req, res, next) => {
    try {
      const period = req.query.period ?? "day";
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const stats = await getStats({ userId: req.auth.userId, timezone, period });
      return res.json(stats);
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
