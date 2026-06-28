import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../utils/service_locator.dart';
import '../../common/widgets/side_drawer.dart';
import '../data/models/appointment_model.dart';
import '../data/repositories/appointment_repository.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _repo = getIt<AppointmentRepository>();
  late Future<List<Appointment>> _futureAppointments;

  @override
  void initState() {
    super.initState();
    _futureAppointments = _repo.getAllAppointments();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureAppointments = _repo.getAllAppointments();
    });
    await _futureAppointments;
  }

  Future<void> _onAdd() async {
    final result = await GoRouter.of(context).push(
      '${RouteNames.appointments}/add',
    );
    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _onDelete(Appointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete appointment for "${appointment.patientName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repo.deleteAppointment(appointment.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment deleted')),
          );
          await _refresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text('No appointments yet'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Appointment'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final apt = appointments[index];
        final dateStr = DateFormat('MMM dd, yyyy').format(apt.appointmentDate);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12),
              child: Text(
                apt.patientName.isNotEmpty
                    ? apt.patientName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              apt.patientName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('$dateStr • ${apt.startTime} - ${apt.endTime}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: apt.appointmentType == 'New'
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        apt.appointmentType,
                        style: TextStyle(
                          fontSize: 12,
                          color: apt.appointmentType == 'New'
                              ? Colors.orange.shade800
                              : Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(apt.status).withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        apt.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(apt.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _onDelete(apt),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      drawer: const SideDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Appointment>>(
          future: _futureAppointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text('Failed to load appointments: ${snapshot.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final appointments = snapshot.data ?? [];
            return _buildList(appointments);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        tooltip: 'Add Appointment',
        child: const Icon(Icons.add),
      ),
    );
  }
}