import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'create_visit_screen.dart';
import 'visit_detail_screen.dart';
import 'ai_summary_screen.dart';

class VisitLogsScreen extends StatefulWidget {
  const VisitLogsScreen({super.key});

  @override
  State<VisitLogsScreen> createState() => _VisitLogsScreenState();
}

class _VisitLogsScreenState extends State<VisitLogsScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  /// STATUS COLOR
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "synced":
        return Colors.greenAccent;

      case "syncing":
        return Colors.blueAccent;

      case "failed":
        return Colors.redAccent;

      case "draft":
        return Colors.grey;

      default:
        return Colors.white24;
    }
  }

  /// FAKE SYNC FUNCTION
  Future<void> syncVisit(dynamic key) async {
    final box = Hive.box('visits');

    final visit = Map<String, dynamic>.from(box.get(key));

    visit["syncStatus"] = "syncing";
    await box.put(key, visit);

    await Future.delayed(const Duration(seconds: 2));

    bool success = DateTime.now().second % 2 == 0;

    visit["syncStatus"] = success ? "synced" : "failed";

    await box.put(key, visit);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('visits');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Visit Logs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Column(
          children: [
            /// SEARCH
            TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),

              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search customer...',
                hintStyle: const TextStyle(color: Colors.white38),

                prefixIcon: const Icon(Icons.search, color: Colors.white38),

                filled: true,
                fillColor: const Color(0xFF1A1A1A),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// VISIT LIST
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),

                builder: (context, Box box, _) {
                  final keys = box.keys.toList();

                  final filteredKeys = keys.where((key) {
                    final visit = Map<String, dynamic>.from(box.get(key) ?? {});

                    final name = visit["customerName"].toString().toLowerCase();

                    return name.contains(searchQuery);
                  }).toList();

                  if (filteredKeys.isEmpty) {
                    return const Center(
                      child: Text(
                        "No visits found",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredKeys.length,

                    itemBuilder: (context, index) {
                      final key = filteredKeys[index];

                      final visit = Map<String, dynamic>.from(
                        box.get(key) ?? {},
                      );

                      final syncStatus = visit["syncStatus"] ?? "draft";

                      final followUp = visit["followUpDate"] ?? "No follow up";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VisitDetailScreen(visit: visit, hiveKey: key),
                            ),
                          );
                        },

                        child: LogCard(
                          title: visit["customerName"] ?? "",
                          date: visit["visitDate"] ?? "",
                          description: visit["notes"] ?? "",

                          status: syncStatus.toUpperCase(),

                          accentColor: getStatusColor(syncStatus),

                          followUp: followUp,

                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateVisitLogScreen(
                                  isEdit: true,
                                  hiveKey: key,
                                  existingVisit: visit,
                                ),
                              ),
                            );
                          },

                          onAI: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AIInsightsScreen(visit: visit),
                              ),
                            );
                          },

                          onSync: () {
                            syncVisit(key);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ADD VISIT
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateVisitLogScreen()),
          );
        },
      ),
    );
  }
}

class LogCard extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final String status;
  final String followUp;
  final Color accentColor;

  final VoidCallback onEdit;
  final VoidCallback onAI;
  final VoidCallback onSync;

  const LogCard({
    required this.title,
    required this.date,
    required this.description,
    required this.status,
    required this.followUp,
    required this.accentColor,
    required this.onEdit,
    required this.onAI,
    required this.onSync,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),

        border: Border(
          left: BorderSide(color: accentColor.withOpacity(0.8), width: 4),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                _StatusBadge(status: status, color: accentColor),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: onSync,
                  child: const Icon(
                    Icons.sync,
                    color: Colors.white38,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              date,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),

            const SizedBox(height: 6),

            Text(
              "Next Follow-up: $followUp",
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: onAI,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),

                      border: Border.all(
                        color: Colors.deepPurpleAccent.withOpacity(0.5),
                      ),
                    ),

                    child: Row(
                      children: const [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.deepPurpleAccent,
                          size: 16,
                        ),

                        SizedBox(width: 4),

                        Text(
                          "AI",
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: color.withOpacity(0.3)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          CircleAvatar(radius: 3, backgroundColor: color),

          const SizedBox(width: 4),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
