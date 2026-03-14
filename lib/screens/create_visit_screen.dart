import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CreateVisitLogScreen extends StatefulWidget {
  final bool isEdit;
  final dynamic hiveKey;
  final Map<String, dynamic>? existingVisit;

  const CreateVisitLogScreen({
    super.key,
    this.isEdit = false,
    this.hiveKey,
    this.existingVisit,
  });

  @override
  State<CreateVisitLogScreen> createState() => _CreateVisitLogScreenState();
}

class _CreateVisitLogScreenState extends State<CreateVisitLogScreen> {
  final customerController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? visitDate;
  DateTime? followUpDate;

  String selectedOutcome = 'Follow-up Needed';

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.existingVisit != null) {
      final visit = widget.existingVisit!;

      customerController.text = visit["customerName"] ?? "";
      contactController.text = visit["contactPerson"] ?? "";
      locationController.text = visit["location"] ?? "";
      notesController.text = visit["notes"] ?? "";

      selectedOutcome = visit["outcome"] ?? "Follow-up Needed";

      if (visit["visitDate"] != null &&
          visit["visitDate"].toString().isNotEmpty) {
        visitDate = DateTime.tryParse(visit["visitDate"]);
      }

      if (visit["followUpDate"] != null &&
          visit["followUpDate"].toString().isNotEmpty) {
        followUpDate = DateTime.tryParse(visit["followUpDate"]);
      }
    }
  }

  @override
  void dispose() {
    customerController.dispose();
    contactController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  /// SAVE VISIT
  void saveVisit() async {
    if (customerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Customer name required")));
      return;
    }

    if (selectedOutcome == "Follow-up Needed" && followUpDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Follow-up date required")));
      return;
    }

    final visitData = {
      "customerName": customerController.text.trim(),

      "contactPerson": contactController.text.trim(),

      "location": locationController.text.trim(),

      "visitDate": (visitDate ?? DateTime.now()).toIso8601String(),

      "notes": notesController.text.trim(),

      "outcome": selectedOutcome,

      "followUpDate": followUpDate?.toIso8601String() ?? "",

      /// REQUIRED FOR SYNC SYSTEM
      "syncStatus": widget.isEdit
          ? (widget.existingVisit?["syncStatus"] ?? "draft")
          : "draft",

      /// FOR AI SUMMARY STORAGE
      "aiSummary": widget.existingVisit?["aiSummary"] ?? "",
    };

    final box = Hive.box('visits');

    if (widget.isEdit && widget.hiveKey != null) {
      await box.put(widget.hiveKey, visitData);
    } else {
      await box.add(visitData);
    }

    Navigator.pop(context);
  }

  /// PICK VISIT DATE
  Future<void> pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: visitDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        visitDate = picked;
      });
    }
  }

  /// PICK FOLLOW UP DATE
  Future<void> pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: followUpDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        followUpDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          widget.isEdit ? 'Edit Visit Log' : 'Create Visit Log',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _sectionHeader('Entity Details'),

            _buildTextField('Customer Name', customerController),

            _buildTextField('Contact Person', contactController),

            const SizedBox(height: 24),

            _sectionHeader('Logistics'),

            _buildTextField('Location', locationController),

            _buildDateTimePicker(
              'Visit Date',
              value: visitDate,
              onTap: pickVisitDate,
            ),

            const SizedBox(height: 24),

            _sectionHeader('Engagement Outcome'),

            _buildDropdown(),

            if (selectedOutcome == 'Follow-up Needed') ...[
              _buildDateTimePicker(
                'Next Follow-up Date',
                value: followUpDate,
                onTap: pickFollowUpDate,
              ),
            ],

            const SizedBox(height: 24),

            _sectionHeader('Meeting Notes'),

            _buildNotesArea(),

            const SizedBox(height: 32),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),

          filled: true,
          fillColor: const Color(0xFF1A1A1A),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
    String label, {
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: InkWell(
        onTap: onTap,

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),

          child: Text(
            value == null ? label : "${value.day}/${value.month}/${value.year}",

            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedOutcome,
      dropdownColor: const Color(0xFF1A1A1A),

      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xFF1A1A1A),
      ),

      style: const TextStyle(color: Colors.white),

      items: const [
        DropdownMenuItem(
          value: "Follow-up Needed",
          child: Text("Follow-up Needed"),
        ),

        DropdownMenuItem(value: "Closed", child: Text("Closed")),

        DropdownMenuItem(value: "Negotiation", child: Text("Negotiation")),
      ],

      onChanged: (value) {
        setState(() {
          selectedOutcome = value!;
        });
      },
    );
  }

  Widget _buildNotesArea() {
    return TextField(
      controller: notesController,
      maxLines: 5,

      style: const TextStyle(color: Colors.white),

      decoration: const InputDecoration(
        hintText: "Meeting Notes",
        hintStyle: TextStyle(color: Colors.white38),

        filled: true,
        fillColor: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: saveVisit,

        child: Text(widget.isEdit ? "Update Visit" : "Save Visit"),
      ),
    );
  }
}
