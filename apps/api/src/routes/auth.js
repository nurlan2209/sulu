import { Router } from "express";
import { z } from "zod";
import { validate } from "../middleware/validate.js";
import { loginUser, registerUser } from "../services/authService.js";
import { toUserPublic } from "../serializers/user.js";

const registerSchema = z.object({
  fullName: z.string().min(1).max(80),
  email: z.string().email(),
  password: z.string().min(8).max(128),
  language: z.enum(["kz", "ru"]).optional().default("kz"),
  timezone: z.string().min(1).optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1).max(128)
});

export function authRoutes(env) {
  const r = Router();

  r.post("/register", validate("body", registerSchema), async (req, res, next) => {
    try {
      const { user, token } = await registerUser(env, req.body);
      return res.status(201).json({ token, user: toUserPublic(user) });
    } catch (e) {
      return next(e);
    }
  });

  r.post("/login", validate("body", loginSchema), async (req, res, next) => {
    try {
      const { user, token } = await loginUser(env, req.body);
      return res.json({ token, user: toUserPublic(user) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
