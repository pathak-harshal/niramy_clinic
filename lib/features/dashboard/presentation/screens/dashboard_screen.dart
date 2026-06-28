import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../utils/service_locator.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../common/widgets/side_drawer.dart';
import '../widgets/appointment_calendar.dart';
import '../widgets/dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _appointmentRepo = getIt<AppointmentRepository>();
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  bool _isLoadingAppointments = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoadingAppointments = true;
    });

    try {
      final appointments = await _appointmentRepo.getAppointmentsByDate(
        _selectedDate,
      );
      setState(() {
        _appointments = appointments;
        _isLoadingAppointments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAppointments = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load appointments: $e')),
        );
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAppointments();
  }

  Future<void> _onAddAppointment() async {
    final result = await GoRouter.of(context).push(
      '${RouteNames.appointments}/add',
    );
    if (result == true) {
      _loadAppointments();
    }
  }

  Future<bool?> _showLogoutDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutEvent());
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

  Widget _buildAppointmentsList() {
    if (_isLoadingAppointments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No appointments for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final apt = _appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${apt.startTime} - ${apt.endTime}'),
                  ],
                ),
                const SizedBox(height: 6),
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
            trailing: Icon(
              Icons.chevron_right,
              color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () {
              // Navigate to appointment details or edit
              GoRouter.of(context).push(
                '${RouteNames.appointments}/${apt.id}',
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Niramay Clinic'),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: _onAddAppointment,
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add Appointment',
        ),
        IconButton(
          onPressed: () async {
            final shouldLogout = await _showLogoutDialog(context);

            if (shouldLogout == true && context.mounted) {
              _handleLogout(context);
            }
          },
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
      ],
    ),
    drawer: const SideDrawer(),
    body: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // User has been logged out, redirect to login
          context.go(RouteNames.login);
        } else if (state is AuthFailure) {
          // Show error if logout fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),
              const SizedBox(height: 20),
              AppointmentCalendar(
                initialSelectedDay: _selectedDate,
                onDaySelected: _onDateSelected,
              ),
              const SizedBox(height: 20),
              _buildAppointmentsList(),
            ],
          ),
        ),
      ),
    ),
  );
}