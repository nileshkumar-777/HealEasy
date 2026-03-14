import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIInsightsScreen extends StatefulWidget {
  final Map visit;

  const AIInsightsScreen({super.key, required this.visit});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  String aiResult = "";
  bool loading = false;

  void generateAI() async {
    setState(() {
      loading = true;
    });

    final result = await AIService.generateSummary(widget.visit["notes"] ?? "");

    setState(() {
      aiResult = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.visit["notes"] ?? "No notes available.";

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text('AI Insights', style: TextStyle(color: Colors.white)),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 20),

                Text(
                  'WORKSPACE / RESEARCH',
                  style: TextStyle(
                    color: Colors.blueAccent.withOpacity(0.8),
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Raw Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),

                const SizedBox(height: 24),

                /// RAW NOTES CARD
                _card(notes),

                const SizedBox(height: 24),

                /// AI RESULT
                if (loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (aiResult.isNotEmpty) ...[
                  const Text(
                    "AI Insights",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _card(aiResult),
                ],

                const SizedBox(height: 120),
              ],
            ),
          ),

          /// BUTTON
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildAISummaryButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String text) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildAISummaryButton() {
    return Container(
      width: double.infinity,
      height: 56,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        gradient: const LinearGradient(
          colors: [Color(0xFFC095FF), Color(0xFF5DB8FF)],
        ),
      ),

      child: ElevatedButton.icon(
        onPressed: loading ? null : generateAI,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        icon: const Icon(Icons.bolt, color: Colors.black),

        label: const Text(
          'Generate AI Summary',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
