import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'time_selector.dart';
import '../services/reservation_service.dart';
import '../services/zone_service.dart';
import 'my_boats.dart';
import 'login.dart';
import 'register.dart';
import 'about.dart';
import '../widgets/zone_search.dart';

import '../data/fake_spots.dart';
import '../models/docking_spot.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int markerRefresh = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final MapController mapController = MapController();

  LatLng center = LatLng(45.5481, 13.7302);
  List<Map<String, dynamic>> anchorPoints = [];
  List<Map<String, dynamic>> reservations = [];

  double mapRotation = 0.0;
  bool mapReady = false;

  List<Map<String, dynamic>> zones = [];
  List<Map<String, dynamic>> filteredZones = [];
  final zoneService = ZoneService();
  final zoneSearchController = TextEditingController();

  Future<void> loadZones() async {
    try {
      final data = await Supabase.instance.client
          .from('anchor_zones')
          .select()
          .eq('active', true);

      debugPrint("ZONES RAW: $data");

      setState(() {
        zones = List<Map<String, dynamic>>.from(data);
        filteredZones = zones;
      });
    } catch (e) {
      debugPrint("ZONE LOAD ERROR: $e");
    }
  }

  void searchZones(String query) {
    final q = query.toLowerCase();

    setState(() {
      filteredZones = zones.where((z) {
        final name = (z['name'] ?? '').toString().toLowerCase();
        final desc = (z['description'] ?? '').toString().toLowerCase();

        return name.contains(q) || desc.contains(q);
      }).toList();
    });
  }

  Future<void> loadAnchorPoints() async {
    final points = await Supabase.instance.client
        .from('anchor_points')
        .select();

    final res = await Supabase.instance.client.from('reservations').select();

    setState(() {
      anchorPoints = List<Map<String, dynamic>>.from(points);
      reservations = List<Map<String, dynamic>>.from(res);
    });
  }

  // bool isReserved(String pointId) {
  //   return reservations.any(
  //     (r) =>
  //         r['anchor_point_id'].toString() == pointId.toString() &&
  //         r['status'] == 'reserved',
  //   );
  // }

  bool isReserved(String pointId) {
    final now = DateTime.now().toUtc();

    return reservations.any((r) {
      final samePoint = r['anchor_point_id'].toString() == pointId.toString();

      final active = r['status'] == 'reserved';

      final endTime = DateTime.parse(r['end_time']).toUtc();

      final notExpired = endTime.isAfter(now);

      return samePoint && active && notExpired;
    });
  }

  List<Marker> buildMarkers() {
    final rotationRad = -mapRotation * (3.1415926535 / 180);
    return anchorPoints.map((point) {
      final reserved = isReserved(point['id'].toString());
      return Marker(
        point: LatLng(point['latitude'], point['longitude']),
        width: 40,
        height: 40,
        child: Transform.rotate(
          angle: rotationRad,
          child: Icon(
            Icons.sailing_outlined,
            color: reserved ? Colors.red : Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> getNearbyPoints() {
    const distance = Distance();
    const maxRange = 500;

    final filtered = anchorPoints.where((p) {
      final reserved = isReserved(p['id'].toString());
      if (reserved) return false;
      final d = distance(LatLng(p['latitude'], p['longitude']), center);
      return d <= maxRange;
    }).toList();

    filtered.sort((a, b) {
      final d1 = distance(LatLng(a['latitude'], a['longitude']), center);
      final d2 = distance(LatLng(b['latitude'], b['longitude']), center);
      return d1.compareTo(d2);
    });

    return filtered;
  }

  Map<String, dynamic>? boatStatus;
  Future<void> loadBoatStatus() async {
    final data = await ReservationService().getActiveBoatStatus();

    // print("🚤 BOAT STATUS RAW: $data");

    setState(() {
      boatStatus = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAnchorPoints();
    loadZones();
    loadBoatStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      // SIDE MENU
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                height: 140,
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).primaryColor,
                child: Text(
                  "EasyDock",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),

              // MAIN CONTENT (scrollable)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (Supabase.instance.client.auth.currentUser == null) ...[
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text("Login"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text("Register"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          Supabase.instance.client.auth.currentUser?.email ??
                              "",
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text("Logout"),
                        onTap: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.directions_boat),
                        title: const Text("My Boat[s]"),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BoatsScreen(),
                            ),
                          );
                          await loadBoatStatus();
                          setState(() {});
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // 🔥 THIS IS THE IMPORTANT PART (TRUE BOTTOM PIN)
              const Divider(height: 1),

              SizedBox(
                width: double.infinity,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,

              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // 👈 THIS enables desktop gestures
              ),

              onMapReady: () {
                setState(() {
                  mapReady = true;
                });
              },

              onPositionChanged: (position, hasGesture) {
                setState(() {
                  center = position.center;
                  mapRotation = position.rotation;
                });
              },
            ),
            // options: MapOptions(
            //   initialCenter: center,
            //   initialZoom: 14,
            //   onMapReady: () {
            //     setState(() {
            //       mapReady = true;
            //     });
            //   },

            //   onPositionChanged: (position, hasGesture) {
            //     setState(() {
            //       center = position.center;
            //       mapRotation = position.rotation;
            //     });
            //   },

            //   // onTap: (tapPosition, latLng) {
            //   //   setState(() {
            //   //     fakeSpots.add(
            //   //       DockingSpot(
            //   //         lat: latLng.latitude,
            //   //         lng: latLng.longitude,
            //   //         available: true,
            //   //       ),
            //   //     );
            //   //   });
            //   // },
            // ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                retinaMode: RetinaMode.isHighDensity(context),
              ),

              MarkerLayer(
                key: ValueKey(markerRefresh),
                markers: mapReady ? buildMarkers() : [],
              ),
            ],
          ),

          // CENTER PIN
          IgnorePointer(
            child: Center(
              child: Icon(
                Icons.location_pin,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // SEARCH BUTTON
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: "search_btn",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              // onPressed: () {
              //   showModalBottomSheet(
              //     context: context,
              //     isScrollControlled: true,
              //     builder: (_) => ZoneSearchSheet(
              //       zones: zones,
              //       mapController: mapController,

              //     ),
              //   );
              //   loadZones();
              //   setState(() {});
              // },
              onPressed: () async {
                await loadZones(); // make sure latest data first

                if (!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ZoneSearchSheet(
                    zones: zones,
                    mapController: mapController,
                  ),
                );
              },
              child: const Icon(Icons.search_outlined, size: 35),
            ),
          ),

          // PROFILE / MENU BUTTON
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton(
              heroTag: "profile_btn",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
              child: const Icon(Icons.account_circle_outlined, size: 35),
            ),
          ),

          // BOTTOM DRAGGABLE SHEET
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.25,
                minChildSize: 0.2,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 50, 195, 137),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.8),
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Icon(
                            Icons.drag_handle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        ListTile(
                          title: const Text(
                            "Center location",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "${center.latitude.toStringAsFixed(5)}, "
                            "${center.longitude.toStringAsFixed(5)}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),

                        if (boatStatus != null) ...[
                          ListTile(
                            title: const Text(
                              "Active Boat Status",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Anchor: ${boatStatus!['anchor']?['name']} "
                              "(${boatStatus!['anchor']?['latitude']}, "
                              "${boatStatus!['anchor']?['longitude']})",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],

                        ...getNearbyPoints().map((point) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor, // semi-transparent dark card
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(blue: 10),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),

                              title: Text(
                                "Anchor point: ${point['name']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              subtitle: Text(
                                "Depth: ${point['depth_m']} m",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.white54,
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TimeSelectorPage(
                                      anchorPointId: point['id'].toString(),
                                    ),
                                  ),
                                );

                                await Future.wait([
                                  loadBoatStatus(),
                                  loadAnchorPoints(),
                                ]);

                                setState(() {
                                  markerRefresh++;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
