import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BoatsScreen extends StatefulWidget {
  const BoatsScreen({super.key});

  @override
  State<BoatsScreen> createState() => _BoatsScreenState();
}

class _BoatsScreenState extends State<BoatsScreen> {
  final client = Supabase.instance.client;

  List<Map<String, dynamic>> boats = [];
  String? activeBoatId;

  @override
  void initState() {
    super.initState();
    loadBoats();
    loadActiveBoat();
  }

  Future<void> loadBoats() async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final res = await client.from('boat_type').select().eq('owner_id', user.id);

    setState(() {
      boats = List<Map<String, dynamic>>.from(res);
    });
  }

  Future<void> setActiveBoat(String boatId) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await client
        .from('profiles')
        .update({'active_boat_id': boatId})
        .eq('id', user.id);

    setState(() {
      activeBoatId = boatId;
    });
  }

  Future<void> addBoat(String name, String reg) async {
    final user = client.auth.currentUser!;
    await client.from('boat_type').insert({
      'owner_id': user.id,
      'boat_name': name,
      'registration_number': reg,
    });

    await loadBoats();
  }

  Future<void> loadActiveBoat() async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final res = await client
        .from('profiles')
        .select('active_boat_id')
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      activeBoatId = res?['active_boat_id']?.toString();
    });
  }

  void openAddDialog() {
    final name = TextEditingController();
    final reg = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add boat"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: reg,
              decoration: const InputDecoration(labelText: "Registration"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await addBoat(name.text, reg.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Boats")),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: boats.map((b) {
          final selected = b['id'] == activeBoatId;
          return ListTile(
            leading: const Icon(Icons.directions_boat),

            title: Text((b['boat_name'] ?? 'Unnamed boat').toString()),

            subtitle: Text((b['registration_number'] ?? 'No reg').toString()),

            trailing: selected
                ? const Icon(Icons.check, color: Colors.green)
                : null,

            onTap: () => setActiveBoat(b['id'].toString()),
          );
        }).toList(),
      ),
    );
  }
}
