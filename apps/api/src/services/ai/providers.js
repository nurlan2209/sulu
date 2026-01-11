import { GoogleGenAI } from "@google/genai";
import { ApiError } from "../../errors/ApiError.js";

class DisabledProvider {
  async generateInsight() {
    throw new ApiError(503, "ai_disabled", "AI provider is disabled");
  }
}

class GeminiProvider {
  constructor(apiKey) {
    this.ai = new GoogleGenAI({ apiKey });
  }

  async generateInsight(input) {
    const system =
      "You are DAMU APP assistant. Produce short habit insights about drinking water. No medical advice. No diagnosis. No treatment. Be motivational but concise.";
    const user = {
      task: "Analyze water drinking habit and produce insights",
      period: input.period,
      language: input.language,
      constraints: [
        "No medical advice",
        "Max 5 bullet points",
        "Suggest 2-3 optimal times to drink water",
        "Use user's language",
        "Keep under 600 characters if possible"
      ],
      data: input.payload
    };

    const response = await this.ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents: `${system}\n\n${JSON.stringify(user)}`,
    });

    const text = response?.text;
    if (typeof text !== "string" || !text.trim()) throw new ApiError(502, "ai_invalid_response", "AI invalid response");
    return text.trim();
  }
}

export function createAIProvider(env) {
  if (env.AI_PROVIDER === "disabled") return new DisabledProvider();
  if (env.AI_PROVIDER === "gemini") {
    if (!env.GEMINI_API_KEY) throw new ApiError(500, "misconfigured", "GEMINI_API_KEY is required when AI_PROVIDER=gemini");
    return new GeminiProvider(env.GEMINI_API_KEY);
  }
  return new DisabledProvider();
}
