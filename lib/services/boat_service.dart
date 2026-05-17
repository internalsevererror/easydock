// import 'package:supabase_flutter/supabase_flutter.dart';

// class BoatService {
//   static final client = Supabase.instance.client;

//   static Future<Map<String, dynamic>?> getMyBoat() async {
//     final user = client.auth.currentUser;
//     if (user == null) return null;

//     final res = await client
//         .from('boat_type')
//         .select()
//         .eq('owner_id', user.id)
//         .maybeSingle();

//     return res;
//   }

//   static Future<void> createBoat({
//     required String name,
//     required String registrationNumber,
//   }) async {
//     final user = client.auth.currentUser;
//     if (user == null) throw Exception("Not logged in");

//     await client.from('boat_type').insert({
//       'owner_id': user.id,
//       'name': name,
//       'registration_number': registrationNumber,
//     });
//   }
// }
import 'package:supabase_flutter/supabase_flutter.dart';

class BoatService {
  static final client = Supabase.instance.client;

  /// Returns ALL boats for current user
  static Future<List<Map<String, dynamic>>> getMyBoats() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final res = await client.from('boat_type').select().eq('owner_id', user.id);

    return List<Map<String, dynamic>>.from(res);
  }

  /// Get active boat id from USER PROFILE (NOT boat table)
  static Future<String?> getActiveBoatId() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final res = await client
        .from('profiles')
        .select('active_boat_id')
        .eq('id', user.id)
        .maybeSingle();

    final value = res?['active_boat_id'];

    if (value == null) return null;

    return value.toString();
  }

  /// Set active boat
  static Future<void> setActiveBoat(String boatId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await client
        .from('profiles')
        .update({'active_boat_id': boatId})
        .eq('id', user.id);
  }

  static Future<void> createBoat({
    required String name,
    required String registrationNumber,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await client.from('boat_type').insert({
      'owner_id': user.id,
      'boat_name': name,
      'registration_number': registrationNumber,
    });
  }
}
