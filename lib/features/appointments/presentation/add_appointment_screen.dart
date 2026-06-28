import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../utils/service_locator.dart';
import '../../patients/data/models/patient_model.dart';
import '../../patients/data/repositories/patient_repository.dart';
import '../data/models/appointment_model.dart';
import 'bloc/appointment_bloc.dart';

class AddAppointmentScreen extends StatefulWidget {
  final String? appointmentId;

  const AddAppointmentScreen({super.key, this.appointmentId});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientRepo = getIt<PatientRepository>();

  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  Patient? _selectedPatient;
  String _searchQuery = '';

  String _selectedAppointmentType = 'New';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isLoadingPatients = true;

  final List<String> _appointmentTypes = ['New', 'Follow Up'];

  @override
  void initState() {
    super.initState();
    _loadPatients();

    if (widget.appointmentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<AppointmentBloc>()
            .add(LoadAppointment(widget.appointmentId!));
      });
    }
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _patientRepo.getAllPatients();
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPatients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load patients: $e')),
        );
      }
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients
            .where(
              (patient) =>
          patient.name.toLowerCase().contains(query.toLowerCase()) ||
              patient.mobileNumber.contains(query),
        )
            .toList();
      }
    });
  }

  Future<void> _onAddNewPatient() async {
    final result =
    await GoRouter.of(context).push('${RouteNames.patients}/add');
    if (result == true) {
      await _loadPatients();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Auto-set end time to 30 minutes later if not set
        if (_endTime == null) {
          final now = DateTime.now();
          final startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            picked.hour,
            picked.minute,
          );
          final endDateTime = startDateTime.add(const Duration(minutes: 30));
          _endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start time')),
      );
      return;
    }
    if (_endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select end time')),
      );
      return;
    }

    // Validate that end time is after start time
    final start = _startTime!.hour * 60 + _startTime!.minute;
    final end = _endTime!.hour * 60 + _endTime!.minute;
    if (end <= start) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final appointment = Appointment(
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.name,
      appointmentType: _selectedAppointmentType,
      appointmentDate: _selectedDate,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
      status: 'Scheduled',
      createdAt: DateTime.now(),
    );

    context.read<AppointmentBloc>().add(AddAppointment(appointment));
  }

  Widget _buildPatientSearchDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Patient',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      if (_isLoadingPatients)
        const Center(child: CircularProgressIndicator())
      else
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterPatients,
                ),
              ),
              const Divider(height: 1),
              // Patient list
              if (_selectedPatient != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    child: Text(
                      _selectedPatient!.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(_selectedPatient!.name),
                  subtitle: Text(_selectedPatient!.mobileNumber),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedPatient = null;
                      });
                    },
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          child: Text(
                            patient.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(patient.name),
                        subtitle: Text(patient.mobileNumber),
                        onTap: () {
                          setState(() {
                            _selectedPatient = patient;
                            _searchQuery = '';
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      // Add new patient button
      TextButton.icon(
        onPressed: _onAddNewPatient,
        icon: const Icon(Icons.person_add),
        label: const Text('Add New Patient'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ],
  );

  Widget _buildAppointmentTypeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Appointment Type',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      Row(
        children: _appointmentTypes.map((type) {
          final isSelected = _selectedAppointmentType == type;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedAppointmentType = type;
                    });
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );

  Widget _buildDateSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Appointment Date',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 12),
              Text(
                DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildTimeSelectors() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Appointment Time',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _selectStartTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startTime != null
                                ? _formatTimeOfDay(_startTime!)
                                : 'Select time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _startTime != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: _selectEndTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endTime != null
                                ? _formatTimeOfDay(_endTime!)
                                : 'Select time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _endTime != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointmentId != null;
    final title = isEdit ? 'Edit Appointment' : 'Add Appointment';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            GoRouter.of(context).pop(true);
          } else if (state is AppointmentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AppointmentLoading && isEdit) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientSearchDropdown(),
                  const SizedBox(height: 20),
                  _buildAppointmentTypeSelector(),
                  const SizedBox(height: 20),
                  _buildDateSelector(),
                  const SizedBox(height: 20),
                  _buildTimeSelectors(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AppointmentLoading ? null : _onSubmit,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: state is AppointmentLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          isEdit
                              ? 'Update Appointment'
                              : 'Book Appointment',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}