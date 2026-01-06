import { v2 as cloudinary } from "cloudinary";

export function initCloudinary(env) {
  const { CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET } = env;
  if (!CLOUDINARY_CLOUD_NAME || !CLOUDINARY_API_KEY || !CLOUDINARY_API_SECRET) {
    throw new Error("Cloudinary env vars are required");
  }
  cloudinary.config({
    cloud_name: CLOUDINARY_CLOUD_NAME,
    api_key: CLOUDINARY_API_KEY,
    api_secret: CLOUDINARY_API_SECRET
  });
  return cloudinary;
}

export async function uploadAvatar(env, dataUrl) {
  const cloud = initCloudinary(env);
  const folder = env.CLOUDINARY_UPLOAD_FOLDER || "damu/avatars";
  const res = await cloud.uploader.upload(dataUrl, {
    folder,
    overwrite: true,
    invalidate: true,
    resource_type: "image",
    transformation: [{ width: 512, height: 512, crop: "fill", gravity: "face", quality: "auto" }]
  });
  return res.secure_url;
}
