export function toUserPublic(user) {
  return {
    _id: user._id.toString(),
    fullName: user.fullName ?? user.name,
    email: user.email,
    weight: user.weight ?? null,
    dailyWaterGoal: user.dailyWaterGoal ?? null,
    language: user.language,
    timezone: user.timezone ?? null,
    avatarUrl: user.avatarUrl ?? null,
    notificationSettings: user.notificationSettings,
    streak: user.streak,
    createdAt: user.createdAt
  };
}
