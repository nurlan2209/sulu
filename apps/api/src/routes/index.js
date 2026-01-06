import { Router } from "express";
import { authRoutes } from "./auth.js";
import { meRoutes } from "./me.js";
import { profileRoutes } from "./profile.js";
import { waterRoutes } from "./water.js";
import { badgesRoutes } from "./badges.js";
import { insightsRoutes } from "./insights.js";
import { notificationsRoutes } from "./notifications.js";
import { statsRoutes } from "./stats.js";

export function routes(env) {
  const r = Router();
  r.use("/auth", authRoutes(env));
  r.use("/me", meRoutes(env));
  r.use("/profile", profileRoutes(env));
  r.use("/water", waterRoutes(env));
  r.use("/stats", statsRoutes(env));
  r.use("/badges", badgesRoutes(env));
  r.use("/insights", insightsRoutes(env));
  r.use("/notifications", notificationsRoutes(env));
  return r;
}
