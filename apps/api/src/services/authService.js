import bcrypt from "bcrypt";
import crypto from "crypto";
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

export async function requestPasswordReset(env, email) {
  const normalizedEmail = normalizeEmail(email);
  const user = await UserModel.findOne({ email: normalizedEmail }).exec();
  if (!user) return null;

  const token = crypto.randomInt(0, 1000000).toString().padStart(6, "0");
  const tokenHash = hashResetToken(token);
  const expiresAt = new Date(Date.now() + env.PASSWORD_RESET_TOKEN_TTL_MINUTES * 60 * 1000);

  user.passwordResetTokenHash = tokenHash;
  user.passwordResetExpiresAt = expiresAt;
  await user.save();

  return { user, token, expiresAt };
}

export async function resetPassword(env, input) {
  const tokenHash = hashResetToken(input.token);
  const user = await UserModel.findOne({
    passwordResetTokenHash: tokenHash,
    passwordResetExpiresAt: { $gt: new Date() }
  }).exec();
  if (!user) throw new ApiError(400, "invalid_reset_token", "Reset link is invalid or expired");

  user.passwordHash = await bcrypt.hash(input.password, env.PASSWORD_BCRYPT_ROUNDS);
  user.passwordResetTokenHash = undefined;
  user.passwordResetExpiresAt = undefined;
  await user.save();

  const token = signToken(env, user._id.toString());
  return { user, token };
}

function hashResetToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}
