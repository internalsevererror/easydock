// import 'package:flutter/material.dart';

// class AboutScreen extends StatelessWidget {
//   const AboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("About EasyDock"),
//       ),
//       body: const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Text(
//           "EasyDock is a smart bouy docking management app that helps you find, reserve, and manage anchor points easily.\n\nVersion 0.0.5-alpha",
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About EasyDock")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "EasyDock is a smart buoy docking management app that helps you find, reserve, and manage anchor points easily.\n\nVersion 0.0.5-alpha",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 👇 IMAGE AT BOTTOM
            SvgPicture.asset('assets/easy-dock-logo.svg', height: 140),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class AboutScreen extends StatelessWidget {
//   const AboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("About EasyDock"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Expanded(
//               child: SingleChildScrollView(
//                 child: Text(
//                   "EasyDock is a smart bouy docking management app that helps you find, reserve, and manage anchor points easily.\n\nVersion 0.0.5-alpha",
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             SvgPicture.asset(
//               'assets/easy-dock-logo.svg',
//               height: 140,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
