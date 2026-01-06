import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(8080),
  MONGO_URI: z.string().min(1),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().min(1).default("7d"),
  PASSWORD_BCRYPT_ROUNDS: z.coerce.number().int().min(10).max(15).default(12),
  CORS_ORIGIN: z.string().default(""),
  AI_PROVIDER: z.enum(["gemini", "disabled"]).default("disabled"),
  GEMINI_API_KEY: z.string().optional(),
  GEMINI_MODEL: z.string().optional(),
  CRON_TIMEZONE: z.string().default("UTC"),
  CLOUDINARY_CLOUD_NAME: z.string().optional(),
  CLOUDINARY_API_KEY: z.string().optional(),
  CLOUDINARY_API_SECRET: z.string().optional(),
  CLOUDINARY_UPLOAD_FOLDER: z.string().optional()
});

export function loadEnv() {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const issues = parsed.error.issues.map((i) => `${i.path.join(".")}: ${i.message}`).join("\n");
    throw new Error(`Invalid environment:\n${issues}`);
  }

  const env = parsed.data;
  return { ...env, GEMINI_MODEL: "gemini-2.5-flash" };
}
