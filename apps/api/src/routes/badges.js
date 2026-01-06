import { Router } from "express";
import { requireAuth } from "../middleware/requireAuth.js";
import { listBadges } from "../services/gamificationService.js";

export function badgesRoutes(env) {
  const r = Router();
  r.use(requireAuth(env));

  r.get("/", async (req, res, next) => {
    try {
      const badges = await listBadges(req.auth.userId);
      return res.json({ badges });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
