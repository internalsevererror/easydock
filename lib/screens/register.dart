// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final fullNameController = TextEditingController();
//   final usernameController = TextEditingController();
//   final phoneController = TextEditingController();

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool loading = false;

//   Future<void> register() async {
//     setState(() {
//       loading = true;
//     });

//     try {
//       final auth = await Supabase.instance.client.auth.signUp(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       final user = auth.user;

//       if (user != null) {
//         await Supabase.instance.client.from('profiles').upsert({
//           'id': user.id,
//           'full_name': fullNameController.text.trim(),
//           'user_name': usernameController.text.trim(),
//           'phone': phoneController.text.trim(),
//           'updated_at': DateTime.now().toIso8601String(),
//         });
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Registration successful")));

//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     }

//     if (!mounted) return;

//     setState(() {
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Register")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: fullNameController,
//                 decoration: const InputDecoration(labelText: "Full name"),
//               ),

//               const SizedBox(height: 16),

//               TextField(
//                 controller: usernameController,
//                 decoration: const InputDecoration(labelText: "Username"),
//               ),

//               const SizedBox(height: 16),

//               TextField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(labelText: "Phone"),
//               ),

//               const SizedBox(height: 16),

//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//               ),

//               const SizedBox(height: 16),

//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password"),
//               ),

//               const SizedBox(height: 30),

//               ElevatedButton(
//                 onPressed: loading ? null : register,
//                 child: loading
//                     ? const CircularProgressIndicator()
//                     : const Text("Register"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullName = TextEditingController();
  final username = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);

    final client = Supabase.instance.client;

    try {
      final res = await client.auth.signUp(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception("Signup failed");

      // ✅ UPSERT prevents duplicate crash
      await client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName.text.trim(),
        'user_name': username.text.trim(),
        'phone': phone.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registered")));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: fullName,
                  decoration: const InputDecoration(labelText: "Full name"),
                ),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : register,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
