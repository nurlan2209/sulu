import express from "express";
import helmet from "helmet";
import cors from "cors";
import morgan from "morgan";
import rateLimit from "express-rate-limit";
import { errorHandler } from "./middleware/errorHandler.js";
import { routes } from "./routes/index.js";

export function createApp(env) {
  const app = express();
  app.use(helmet());
  app.use(express.json({ limit: "1mb" }));
  app.use(morgan(env.NODE_ENV === "production" ? "combined" : "dev"));

  const origins = env.CORS_ORIGIN.split(",").map((s) => s.trim()).filter(Boolean);
  const corsMiddleware = cors({
    origin: (origin, cb) => {
      if (!origin) return cb(null, true);
      if (env.NODE_ENV !== "production") {
        if (/^https?:\/\/localhost:\d+$/.test(origin) || /^https?:\/\/127\.0\.0\.1:\d+$/.test(origin)) return cb(null, true);
      }
      if (!origins.length) return cb(null, env.NODE_ENV === "production" ? false : true);
      return cb(null, origins.includes(origin));
    },
    credentials: true
  });
  app.use(corsMiddleware);
  app.options("*", corsMiddleware);

  app.use(
    rateLimit({
      windowMs: 60000,
      limit: 120,
      standardHeaders: "draft-7",
      legacyHeaders: false,
      skip: (req) => req.method === "OPTIONS"
    })
  );

  app.get("/health", (_req, res) => res.json({ ok: true }));
  app.use("/v1", routes(env));
  app.use(errorHandler());
  return app;
}
