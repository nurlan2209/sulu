import mongoose from "mongoose";

const BadgeSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    type: { type: String, required: true, enum: ["3_days_streak", "100_percent_day"] },
    earnedAt: { type: Date, required: true, default: () => new Date() }
  },
  { timestamps: false }
);

BadgeSchema.index({ userId: 1, type: 1 }, { unique: false });

export const BadgeModel = mongoose.model("Badge", BadgeSchema);
