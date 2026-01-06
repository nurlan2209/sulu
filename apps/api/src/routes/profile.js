import { Router } from "express";
import { z } from "zod";
import { ApiError } from "../errors/ApiError.js";
import { requireAuth } from "../middleware/requireAuth.js";
import { validate } from "../middleware/validate.js";
import { UserModel } from "../models/User.js";
import { toUserPublic } from "../serializers/user.js";
import { uploadAvatar } from "../utils/cloudinary.js";

const updateSchema = z.object({
  fullName: z.string().min(1).max(80).optional(),
  name: z.string().min(1).max(80).optional(),
  weight: z.number().min(20).max(300).optional(),
  dailyWaterGoal: z.number().min(300).max(20000).optional(),
  recalculateGoal: z.boolean().optional(),
  language: z.enum(["kz", "ru"]).optional(),
  timezone: z.string().min(1).optional()
});

const avatarSchema = z.object({
  dataUrl: z.string().min(20, "dataUrl required")
});

export function profileRoutes(env) {
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

  r.put("/update", validate("body", updateSchema), async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");

      const body = req.body;
      if (body.fullName !== undefined) user.fullName = body.fullName;
      if (body.name !== undefined) user.fullName = body.name;
      if (body.language !== undefined) user.language = body.language;
      if (body.timezone !== undefined) user.timezone = body.timezone;

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

  r.post("/avatar", validate("body", avatarSchema), async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");

      if (!env.CLOUDINARY_CLOUD_NAME || !env.CLOUDINARY_API_KEY || !env.CLOUDINARY_API_SECRET) {
        throw new ApiError(500, "avatar_disabled", "Cloudinary is not configured");
      }

      const url = await uploadAvatar(env, req.body.dataUrl);
      user.avatarUrl = url;
      await user.save();
      return res.json({ user: toUserPublic(user) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
