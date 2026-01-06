import mongoose from "mongoose";

export async function connectMongo(env) {
  mongoose.set("strictQuery", true);
  await mongoose.connect(env.MONGO_URI);
}
