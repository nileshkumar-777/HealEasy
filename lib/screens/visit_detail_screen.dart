import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healeasy/screens/create_visit_screen.dart';

class VisitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> visit;
  final dynamic hiveKey;

  const VisitDetailScreen({
    super.key,
    required this.visit,
    required this.hiveKey,
  });

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('visits');

    /// Always convert Hive map safely
    final visitData = Map<String, dynamic>.from(visit);

    final syncStatus = (visitData["syncStatus"] ?? "draft").toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Visit Details",
          style: TextStyle(color: Colors.white),
        ),

        actions: [
          /// EDIT
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateVisitLogScreen(
                    isEdit: true,
                    hiveKey: hiveKey,
                    existingVisit: visitData,
                  ),
                ),
              );
            },
          ),

          /// DELETE
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),

            onPressed: () async {
              await box.delete(hiveKey);

              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [
            _detailTile("Customer Name", visitData["customerName"]),
            _detailTile("Contact Person", visitData["contactPerson"]),
            _detailTile("Location", visitData["location"]),
            _detailTile("Visit Date", _formatDate(visitData["visitDate"])),
            _detailTile("Outcome", visitData["outcome"]),
            _detailTile(
              "Next Follow-up Date",
              _formatDate(visitData["followUpDate"]),
            ),
            _detailTile("Sync Status", syncStatus.toUpperCase()),
            _detailTile("Meeting Notes", visitData["notes"]),

            const SizedBox(height: 20),

            /// RETRY SYNC BUTTON
            if (syncStatus == "failed")
              ElevatedButton(
                onPressed: () async {
                  final updatedVisit = Map<String, dynamic>.from(visitData);

                  updatedVisit["syncStatus"] = "syncing";

                  await box.put(hiveKey, updatedVisit);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Retry sync clicked")),
                  );
                },
                child: const Text("Retry Sync"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String title, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),

          const SizedBox(height: 6),

          Text(
            value?.toString().isNotEmpty == true
                ? value.toString()
                : "Not added",
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return "Not added";
    }

    try {
      final date = DateTime.parse(value.toString());

      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return value.toString();
    }
  }
}
