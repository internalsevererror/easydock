import 'package:supabase_flutter/supabase_flutter.dart';

class ZoneService {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getActiveZones() async {
    final res = await client
        .from('anchor_zones')
        .select()
        .eq('active', true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> searchZones(String query) async {
    final res = await client
        .from('anchor_zones')
        .select()
        .eq('active', true)
        .ilike('name', '%$query%');

    return List<Map<String, dynamic>>.from(res);
  }
}