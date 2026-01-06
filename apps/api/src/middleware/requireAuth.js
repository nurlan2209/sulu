import jwt from "jsonwebtoken";
import { ApiError } from "../errors/ApiError.js";

export function requireAuth(env) {
  return (req, _res, next) => {
    const header = req.headers.authorization;
    if (!header?.startsWith("Bearer ")) return next(new ApiError(401, "unauthorized", "Missing bearer token"));

    const token = header.slice("Bearer ".length).trim();
    try {
      const payload = jwt.verify(token, env.JWT_SECRET);
      if (!payload?.sub) return next(new ApiError(401, "unauthorized", "Invalid token payload"));
      req.auth = { userId: String(payload.sub) };
      return next();
    } catch {
      return next(new ApiError(401, "unauthorized", "Invalid or expired token"));
    }
  };
}
