# DAMU APP (iOS + Android) + API + AI

Monorepo:
- `apps/mobile` — Flutter app (Clean Architecture + Riverpod)
- `apps/api` — Node.js (TypeScript) + Express + MongoDB + JWT + AI Insights

## Requirements
- Flutter `>=3.35`
- Node `>=20`
- MongoDB (local install or Atlas)
- Docker Desktop (optional, for `docker-compose`)

## Environment
Copy the API env example and fill required values:
- `cp apps/api/.env.example apps/api/.env`

Optional for `docker-compose` overrides, create a root `.env` with:
- `API_PORT`
- `MONGO_INITDB_ROOT_USERNAME`
- `MONGO_INITDB_ROOT_PASSWORD`

## Run backend (without Docker)
Make sure MongoDB is available:
- Atlas: set `MONGO_URI` in `apps/api/.env` to your connection string.
- Local: install MongoDB and set `MONGO_URI=mongodb://127.0.0.1:27017/damu`.

Then run:
```bash
cd apps/api
npm i
npm run dev
```

## Run backend (Docker, optional)
```bash
docker compose up --build
```
API: `http://localhost:8080`

## Run mobile
```bash
cd apps/mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080/v1
```

## Run on physical iPhone
- Find your Mac IP in the same Wi‑Fi network (e.g. `192.168.1.10`).
- Run API so it listens on the Mac and is reachable from the phone.
- Run:
```bash
cd apps/mobile
flutter run -d ios --dart-define=API_BASE_URL=http://192.168.1.10:8080/v1
```

## Run web
```bash
cd apps/mobile
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/v1
```

## Notes
- MongoDB Atlas is supported via `MONGO_URI` env var (recommended for prod).
- AI is called only from backend (Gemini via `AI_PROVIDER=gemini` + `GEMINI_API_KEY`, model `gemini-2.5-flash`).
