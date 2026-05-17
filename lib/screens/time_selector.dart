import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/reservation_service.dart';

class TimeSelectorPage extends StatefulWidget {
  final String anchorPointId;
  final Map<String, dynamic>? existingReservation;

  const TimeSelectorPage({
    super.key,
    required this.anchorPointId,
    this.existingReservation,
  });

  @override
  State<TimeSelectorPage> createState() => _TimeSelectorPageState();
}

class _TimeSelectorPageState extends State<TimeSelectorPage> {
  Duration duration = const Duration(hours: 1);
  DateTime startTime = DateTime.now();
  bool loading = false;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingReservation;

    if (existing != null) {
      startTime = DateTime.parse(existing['start_time']);
      final endTime = DateTime.parse(existing['end_time']);
      duration = endTime.difference(startTime);
    }
  }

  Future<void> confirm() async {
    setState(() => loading = true);

    final endTime = startTime.add(duration);
    final client = Supabase.instance.client;

    try {
      if (widget.existingReservation != null) {
        final result = await client
            .from('reservations')
            .update({
              'start_time': startTime.toUtc().toIso8601String(),
              'end_time': endTime.toUtc().toIso8601String(),
            })
            .eq('id', widget.existingReservation!['id'])
            .select();

        debugPrint("UPDATE RESULT: $result");
        // await client
        //     .from('reservations')
        //     .update({
        //       'start_time': startTime.toUtc().toIso8601String(),
        //       'end_time': endTime.toUtc().toIso8601String(),
        //     })
        //     .eq('id', widget.existingReservation!['id']);
      } else {
        // await ReservationService().createReservation(
        //   anchorPointId: widget.anchorPointId,
        //   startTime: startTime,
        //   endTime: endTime,
        // );
        await ReservationService().createReservation(
          anchorPointId: widget.anchorPointId,
          startTime: startTime,
          endTime: endTime,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // final endTime = startTime.add(duration);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select time"),
        leading: const BackButton(),
      ),

      body: Stack(
        children: [
          // ✅ MAIN LAYOUT FIX
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                /// CENTERED PICKER (FIXED)
                Center(
                  child: DurationPicker(
                    duration: duration,
                    onChange: (v) => setState(() => duration = v),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Duration: ${duration.inHours}h ${duration.inMinutes.remainder(60)}m",
                  style: const TextStyle(fontSize: 16),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: loading ? null : confirm,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.existingReservation != null
                              ? "Update reservation"
                              : "Create reservation",
                        ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // KEEP: current reservation overlay
          if (widget.existingReservation != null)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current reservation",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Start: ${widget.existingReservation!['start_time']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "End: ${widget.existingReservation!['end_time']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
