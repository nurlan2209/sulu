import { ApiError } from "../errors/ApiError.js";

export function validate(part, schema) {
  return (req, _res, next) => {
    const parsed = schema.safeParse(req[part]);
    if (!parsed.success) {
      return next(new ApiError(400, "validation_error", "Invalid request", parsed.error.flatten()));
    }
    req[part] = parsed.data;
    return next();
  };
}
