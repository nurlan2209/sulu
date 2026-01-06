import { Router } from "express";
import { ApiError } from "../errors/ApiError.js";
import { requireAuth } from "../middleware/requireAuth.js";
import { UserModel } from "../models/User.js";
import { getNotificationRecommendations } from "../services/notificationService.js";

export function notificationsRoutes(env) {
  const r = Router();
  r.use(requireAuth(env));

  r.get("/recommendations", async (req, res, next) => {
    try {
      const user = await UserModel.findById(req.auth.userId).lean().exec();
      if (!user) throw new ApiError(404, "not_found", "User not found");
      const timezone = user.timezone ?? env.CRON_TIMEZONE;
      const payload = await getNotificationRecommendations({ userId: req.auth.userId, timezone });
      return res.json(payload);
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
