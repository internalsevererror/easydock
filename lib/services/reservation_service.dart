import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationService {
  final client = Supabase.instance.client;

  Future<void> createReservation({
    required String anchorPointId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // get ACTIVE boat from profile
    final profile = await client
        .from('profiles')
        .select('active_boat_id')
        .eq('id', user.id)
        .maybeSingle();

    final boatId = profile?['active_boat_id'];

    final debugCheck = await client
        .from('reservations')
        .select('id, status, boat_id')
        .eq('boat_id', boatId);

    print("🔍 ALL RESERVATIONS FOR BOAT: $debugCheck");

    if (boatId == null) {
      throw Exception("No active boat selected");
    }

    //
    // CANCEL PREVIOUS ACTIVE RESERVATIONS
    //
    final cancelResult = await client
        .from('reservations')
        .update({'status': 'cancelled'})
        .eq('boat_id', boatId)
        .eq('status', 'reserved')
        .select();

    print("🔥 CANCEL RESULT: $cancelResult");

    //
    // CREATE NEW RESERVATION
    //
    await client.from('reservations').insert({
      'anchor_point_id': anchorPointId,
      'boat_id': boatId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': 'reserved',
    });
  }

  Future<Map<String, dynamic>?> getActiveBoatStatus() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    // 1. get active boat
    final profile = await client
        .from('profiles')
        .select('active_boat_id')
        .eq('id', user.id)
        .maybeSingle();

    final boatId = profile?['active_boat_id'];
    if (boatId == null) return null;

    // 2. get latest reservation for that boat
    final res = await client
        .from('reservations')
        .select('''
        id,
        start_time,
        end_time,
        status,
        anchor_point_id
      ''')
        .eq('boat_id', boatId)
        .order('start_time', ascending: false)
        .limit(1)
        .maybeSingle();

    if (res == null) return null;

    // 3. get anchor point details
    final anchor = await client
        .from('anchor_points')
        .select('id, latitude, longitude, name')
        .eq('id', res['anchor_point_id'])
        .maybeSingle();

    return {'reservation': res, 'anchor': anchor, 'boat_id': boatId};
  }
}
