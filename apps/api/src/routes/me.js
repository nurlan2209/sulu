import { Router } from "express";
import { z } from "zod";
import { ApiError } from "../errors/ApiError.js";
import { requireAuth } from "../middleware/requireAuth.js";
import { validate } from "../middleware/validate.js";
import { UserModel } from "../models/User.js";
import { toUserPublic } from "../serializers/user.js";

const patchSchema = z.object({
  fullName: z.string().min(1).max(80).optional(),
  name: z.string().min(1).max(80).optional(),
  weight: z.number().min(20).max(300).optional(),
  recalculateGoal: z.boolean().optional(),
  dailyWaterGoal: z.number().min(300).max(20000).optional(),
  language: z.enum(["kz", "ru"]).optional(),
  timezone: z.string().min(1).optional(),
  notificationSettings: z
    .object({
      enabled: z.boolean(),
      intervalMinutes: z.number().int().min(15).max(360),
      quietHours: z.object({ start: z.string().min(4), end: z.string().min(4) })
    })
    .optional()
});

export function meRoutes(env) {
  const r = Router();
  r.use(requireAuth(env));

  r.get("/", async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      return res.json({ user: toUserPublic(user) });
    } catch (e) {
      return next(e);
    }
  });

  r.patch("/", validate("body", patchSchema), async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");

      const body = req.body;
      if (body.fullName !== undefined) user.fullName = body.fullName;
      if (body.name !== undefined) user.fullName = body.name;
      if (body.language !== undefined) user.language = body.language;
      if (body.timezone !== undefined) user.timezone = body.timezone;
      if (body.notificationSettings !== undefined) user.notificationSettings = body.notificationSettings;

      const weightChanged = body.weight !== undefined && body.weight !== user.weight;
      if (body.weight !== undefined) user.weight = body.weight;

      if (body.dailyWaterGoal !== undefined) {
        user.dailyWaterGoal = body.dailyWaterGoal;
      } else if (weightChanged && body.recalculateGoal) {
        user.dailyWaterGoal = user.weight ? Math.round(user.weight * 30) : undefined;
      }

      await user.save();
      return res.json({ user: toUserPublic(user) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
