import { Router } from "express";
import { z } from "zod";
import { validate } from "../middleware/validate.js";
import { loginUser, registerUser, requestPasswordReset, resetPassword } from "../services/authService.js";
import { createEmailService } from "../services/emailService.js";
import { toUserPublic } from "../serializers/user.js";

const passwordSchema = z
  .string()
  .min(8)
  .max(128)
  .refine((value) => /[A-Z]/.test(value), { message: "Password must include an uppercase letter" })
  .refine((value) => /\d/.test(value), { message: "Password must include a number" })
  .refine((value) => /[^A-Za-z0-9\s]/.test(value), { message: "Password must include a special character" });

const registerSchema = z
  .object({
    fullName: z.string().min(1).max(80),
    email: z.string().email(),
    password: passwordSchema,
    confirmPassword: z.string().min(8).max(128),
    language: z.enum(["kz", "ru"]).optional().default("kz"),
    timezone: z.string().min(1).optional()
  })
  .superRefine((data, ctx) => {
    if (data.password !== data.confirmPassword) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Passwords do not match",
        path: ["confirmPassword"]
      });
    }
  });

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1).max(128)
});

const forgotSchema = z.object({
  email: z.string().email()
});

const resetSchema = z.object({
  token: z.string().regex(/^\d{6}$/, { message: "Token must be 6 digits" }),
  password: z.string().min(8).max(128)
});

export function authRoutes(env) {
  const r = Router();
  const mailer = createEmailService(env);

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

  r.post("/forgot", validate("body", forgotSchema), async (req, res, next) => {
    try {
      const result = await requestPasswordReset(env, req.body.email);
      if (result) {
        const resetLink = env.PASSWORD_RESET_LINK_BASE
          ? `${env.PASSWORD_RESET_LINK_BASE.replace(/\/$/, "")}?token=${result.token}`
          : undefined;
        await mailer.sendPasswordResetEmail({
          to: result.user.email,
          name: result.user.fullName,
          token: result.token,
          resetLink,
          expiresMinutes: env.PASSWORD_RESET_TOKEN_TTL_MINUTES
        });
      }
      return res.json({ ok: true });
    } catch (e) {
      return next(e);
    }
  });

  r.post("/reset", validate("body", resetSchema), async (req, res, next) => {
    try {
      const { user, token } = await resetPassword(env, req.body);
      return res.json({ token, user: toUserPublic(user) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
