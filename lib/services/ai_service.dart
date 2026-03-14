import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const apiKey =
      "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";

  static Future<String> generateSummary(String notes) async {
    final response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-chat",
        "messages": [
          {
            "role": "user",
            "content":
                "Analyze the meeting notes and return ONLY plain text (no markdown symbols like # or *).\n\nFormat:\nMeeting Summary:\nPain Points:\nAction Items:\nNext Step:\n\nNotes:\n$notes",
          },
        ],
      }),
    );

    final data = jsonDecode(response.body);

    return data["choices"][0]["message"]["content"];
  }
}
