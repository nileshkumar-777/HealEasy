import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CreateVisitScreen extends StatefulWidget {
  const CreateVisitScreen({super.key});

  @override
  State<CreateVisitScreen> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends State<CreateVisitScreen> {
  final customerController = TextEditingController();
  final notesController = TextEditingController();

  void saveVisit() {
    var box = Hive.box('visits');

    box.add({
      "customerName": customerController.text,
      "notes": notesController.text,
      "visitDate": DateTime.now().toString(),
      "syncStatus": "draft",
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Visit")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: customerController,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Meeting Notes"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveVisit,
              child: const Text("Save Visit"),
            ),
          ],
        ),
      ),
    );
  }
}
