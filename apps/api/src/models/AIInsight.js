import mongoose from "mongoose";

const AIInsightSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    text: { type: String, required: true, maxlength: 2000 },
    period: { type: String, required: true, enum: ["daily", "weekly"] },
    dayKey: { type: String, required: true },
    createdAt: { type: Date, required: true, default: () => new Date() }
  },
  { timestamps: false }
);

AIInsightSchema.index({ userId: 1, period: 1, dayKey: 1 }, { unique: true });

export const AIInsightModel = mongoose.model("AIInsight", AIInsightSchema);
