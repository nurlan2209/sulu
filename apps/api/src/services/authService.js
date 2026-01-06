import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { ApiError } from "../errors/ApiError.js";
import { UserModel } from "../models/User.js";

function normalizeEmail(email) {
  return email.trim().toLowerCase();
}

export async function registerUser(env, input) {
  const email = normalizeEmail(input.email);
  const existing = await UserModel.findOne({ email }).lean().exec();
  if (existing) throw new ApiError(409, "email_taken", "Email is already registered");

  const passwordHash = await bcrypt.hash(input.password, env.PASSWORD_BCRYPT_ROUNDS);

  const user = await UserModel.create({
    fullName: input.fullName,
    name: input.fullName,
    email,
    passwordHash,
    language: input.language,
    timezone: input.timezone
  });

  const token = signToken(env, user._id.toString());
  return { user, token };
}

export async function loginUser(env, input) {
  const email = normalizeEmail(input.email);
  const user = await UserModel.findOne({ email }).exec();
  if (!user) throw new ApiError(401, "invalid_credentials", "Invalid email or password");

  const ok = await bcrypt.compare(input.password, user.passwordHash);
  if (!ok) throw new ApiError(401, "invalid_credentials", "Invalid email or password");

  const token = signToken(env, user._id.toString());
  return { user, token };
}

export function signToken(env, userId) {
  return jwt.sign({}, env.JWT_SECRET, { subject: userId, expiresIn: env.JWT_EXPIRES_IN });
}
