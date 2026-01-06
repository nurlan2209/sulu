import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/requireAuth.js";
import { validate } from "../middleware/validate.js";
import { getOrCreateInsight, listInsights } from "../services/ai/insightService.js";

const querySchema = z.object({
  period: z.enum(["daily", "weekly"]).default("daily")
});

export function insightsRoutes(env) {
  const r = Router();
  r.use(requireAuth(env));

  r.get("/", validate("query", querySchema), async (req, res, next) => {
    try {
      const insight = await getOrCreateInsight(env, { userId: req.auth.userId, period: req.query.period });
      return res.json({ insight });
    } catch (e) {
      return next(e);
    }
  });

  // Alias for product spec
  r.get("/today", async (req, res, next) => {
    try {
      const insight = await getOrCreateInsight(env, { userId: req.auth.userId, period: "daily" });
      return res.json({ insight });
    } catch (e) {
      return next(e);
    }
  });

  r.get("/history", validate("query", querySchema), async (req, res, next) => {
    try {
      const insights = await listInsights(req.auth.userId, req.query.period);
      return res.json({ insights });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
