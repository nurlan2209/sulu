import mongoose from "mongoose";

const WaterLogSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    amount: { type: Number, required: true, min: 1, max: 5000 },
    temperature: { type: Number, required: false, min: 0, max: 100 }
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

WaterLogSchema.index({ userId: 1, createdAt: -1 });

export const WaterLogModel = mongoose.model("WaterLog", WaterLogSchema);
