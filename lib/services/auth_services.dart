// import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final supabase = Supabase.instance.client;

//   Future<void> signUp(String email, String password) async {
//     await supabase.auth.signUp(
//       email: email,
//       password: password,
//     );
//   }

//   Future<void> signIn(String email, String password) async {
//     await supabase.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );
//   }

//   Future<void> signOut() async {
//     await supabase.auth.signOut();
//   }

//   User? get currentUser => supabase.auth.currentUser;
// }

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final supabase = Supabase.instance.client;

  /// SIGN UP
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userName,
    required String phone,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'user_name': userName,
        'phone': phone,
      },
    );

    final user = res.user;
    if (user == null) return;

    // OPTIONAL if you did NOT use SQL trigger
    await supabase.from('profiles').insert({
      'id': user.id,
      'full_name': fullName,
      'user_name': userName,
      'phone': phone,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// LOGIN
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// CURRENT USER
  String? get userId => supabase.auth.currentUser?.id;

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}