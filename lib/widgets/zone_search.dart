// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_map/flutter_map.dart';

// class ZoneSearchSheet extends StatefulWidget {
//   final List<Map<String, dynamic>> zones;
//   final List<Map<String, dynamic>> filteredZones;
//   final Function(String) onSearch;
//   final MapController mapController;

//   const ZoneSearchSheet({
//     super.key,
//     required this.zones,
//     required this.filteredZones,
//     required this.onSearch,
//     required this.mapController,
//   });

//   @override
//   State<ZoneSearchSheet> createState() => _ZoneSearchSheetState();
// }

// class _ZoneSearchSheetState extends State<ZoneSearchSheet> {
//   final TextEditingController controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     // 🔥 Forces UI updates while typing (not just on keyboard close)
//     controller.addListener(() {
//       widget.onSearch(controller.text);
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.75,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 10),
//           const Icon(Icons.drag_handle),

//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: "Search zones...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),

//           const Divider(),

//           Expanded(
//             child: ListView.builder(
//               itemCount: widget.filteredZones.length, // 🔥 REQUIRED
//               itemBuilder: (context, index) {
//                 final zone = widget.filteredZones[index];

//                 return ListTile(
//                   leading: const Icon(Icons.place),
//                   title: Text(zone['name'] ?? ''),
//                   subtitle: Text(zone['description'] ?? ''),
//                   onTap: () {
//                     Navigator.pop(context);

//                     widget.mapController.move(
//                       LatLng(zone['latitude'], zone['longitude']),
//                       15,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class ZoneSearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> zones;
  final MapController mapController;

  const ZoneSearchSheet({
    super.key,
    required this.zones,
    required this.mapController,
  });

  @override
  State<ZoneSearchSheet> createState() => _ZoneSearchSheetState();
}

class _ZoneSearchSheetState extends State<ZoneSearchSheet> {
  final TextEditingController controller = TextEditingController();

  late List<Map<String, dynamic>> filteredZones;

  @override
  void initState() {
    super.initState();
    filteredZones = widget.zones;
  }

  void search(String query) {
    final q = query.toLowerCase();

    setState(() {
      filteredZones = widget.zones.where((z) {
        final name = (z['name'] ?? '').toString().toLowerCase();
        final desc = (z['description'] ?? '').toString().toLowerCase();
        return name.contains(q) || desc.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.drag_handle),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              onChanged: search,
              decoration: InputDecoration(
                hintText: "Search zones...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: filteredZones.length,
              itemBuilder: (context, index) {
                final zone = filteredZones[index];

                return ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(zone['name'] ?? ''),
                  subtitle: Text(zone['description'] ?? ''),
                  onTap: () {
                    Navigator.pop(context);

                    widget.mapController.move(
                      LatLng(zone['latitude'], zone['longitude']),
                      15,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}