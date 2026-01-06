import { ApiError } from "../errors/ApiError.js";

export function errorHandler() {
  return (err, _req, res, _next) => {
    if (err instanceof ApiError) {
      return res.status(err.status).json({ error: { code: err.code, message: err.message, details: err.details } });
    }
    // eslint-disable-next-line no-console
    console.error(err);
    return res.status(500).json({ error: { code: "internal_error", message: "Internal server error" } });
  };
}
