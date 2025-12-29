import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/action_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user status when screen initializes
    Future.delayed(Duration.zero, () {
      context.read<AttendanceBloc>().add(LoadUserStatusRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Registry"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().logout(),
          )
        ],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AttendanceFailure) {
            _showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          // If loading, show spinner and block interactions
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Determine current status
          String currentStatus = 'OUTSIDE'; // default
          if (state is AttendanceLoaded) {
            currentStatus = state.currentStatus;
          } else if (state is AttendanceSuccess && state.newStatus != null) {
            currentStatus = state.newStatus!;
          }

          final isInside = currentStatus == 'INSIDE';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_city, size: 100, color: Colors.blueGrey),
                const SizedBox(height: 40),
                Text(
                  "Current Status: $currentStatus",
                  style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select Campus Action",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                
                // Show "Enter Campus" button if OUTSIDE
                if (!isInside)
                  ActionButton(
                    label: "ENTER CAMPUS",
                    color: Colors.green.shade600,
                    icon: Icons.login,
                    onTap: () => context.read<AttendanceBloc>().add(CheckInRequested()),
                  ),
                
                // Show "Leave Campus" button if INSIDE
                if (isInside)
                  ActionButton(
                    label: "LEAVE CAMPUS",
                    color: Colors.red.shade600,
                    icon: Icons.logout,
                    onTap: () => context.read<AttendanceBloc>().add(CheckOutRequested()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Registration Failed"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }
}