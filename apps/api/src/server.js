import { loadEnv } from "./config/env.js";
import { connectMongo } from "./db/mongo.js";
import { createApp } from "./app.js";
import { registerJobs } from "./jobs/registerJobs.js";

async function main() {
  const env = loadEnv();
  await connectMongo(env);
  const app = createApp(env);
  registerJobs(env);

  app.listen(env.PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`DAMU API listening on :${env.PORT}`);
  });
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
