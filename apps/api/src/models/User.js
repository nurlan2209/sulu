import mongoose from "mongoose";

const QuietHoursSchema = new mongoose.Schema(
  {
    start: { type: String, required: true },
    end: { type: String, required: true }
  },
  { _id: false }
);

const NotificationSettingsSchema = new mongoose.Schema(
  {
    enabled: { type: Boolean, required: true, default: true },
    intervalMinutes: { type: Number, required: true, default: 90, min: 15, max: 360 },
    quietHours: { type: QuietHoursSchema, required: true, default: { start: "22:00", end: "08:00" } }
  },
  { _id: false }
);

const UserSchema = new mongoose.Schema(
  {
    fullName: { type: String, required: true, trim: true, minlength: 1, maxlength: 80 },
    // Backward-compat for older clients/data
    name: { type: String, required: false, trim: true, minlength: 1, maxlength: 80 },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true, index: true },
    passwordHash: { type: String, required: true },
    weight: { type: Number, required: false, min: 20, max: 300 },
    dailyWaterGoal: { type: Number, required: false, min: 300, max: 20000 },
    language: { type: String, required: true, enum: ["kz", "ru"], default: "kz" },
    timezone: { type: String, required: false },
    avatarUrl: { type: String, required: false, trim: true },
    notificationSettings: { type: NotificationSettingsSchema, required: true, default: () => ({}) },
    streak: { type: Number, required: true, default: 0, min: 0 }
  },
  { timestamps: { createdAt: true, updatedAt: true } }
);

UserSchema.pre("validate", function (next) {
  if (!this.fullName && this.name) this.fullName = this.name;
  if (!this.name && this.fullName) this.name = this.fullName;
  if (this.language !== "kz" && this.language !== "ru") this.language = "kz";
  next();
});

export const UserModel = mongoose.model("User", UserSchema);
