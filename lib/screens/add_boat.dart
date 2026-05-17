import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBoatScreen extends StatefulWidget {
  const AddBoatScreen({super.key});

  @override
  State<AddBoatScreen> createState() => _AddBoatScreenState();
}

class _AddBoatScreenState extends State<AddBoatScreen> {
  final nameController = TextEditingController();
  final regController = TextEditingController();

  bool loading = false;

  Future<void> createBoat() async {
    setState(() => loading = true);

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client.from('boat_type').insert({
      'owner_id': user.id,
      'boat_name': nameController.text.trim(),
      'registration_number': regController.text.trim(),
    });

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Boat")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Boat name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: regController,
              decoration: const InputDecoration(labelText: "Registration number"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : createBoat,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Save Boat"),
            ),
          ],
        ),
      ),
    );
  }
}