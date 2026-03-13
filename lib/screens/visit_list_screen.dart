import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VisitListScreen extends StatelessWidget {
  const VisitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('visits');

    return Scaffold(
      appBar: AppBar(title: const Text("Visit Logs")),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No visits yet"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final visit = box.getAt(index);

              return ListTile(
                title: Text(visit["customerName"]),
                subtitle: Text(visit["notes"]),
                trailing: Text(visit["syncStatus"]),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/createVisit");
        },
      ),
    );
  }
}
