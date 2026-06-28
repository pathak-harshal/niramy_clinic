import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../utils/service_locator.dart';
import '../../patients/data/models/patient_model.dart';
import '../../patients/data/repositories/patient_repository.dart';
import '../data/models/visit_model.dart';
import 'bloc/visit_bloc.dart';

class AddVisitScreen extends StatefulWidget {
  final String? visitId;
  final String? initialPatientId;
  final String? initialPatientName;

  const AddVisitScreen({
    super.key,
    this.visitId,
    this.initialPatientId,
    this.initialPatientName,
  });

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientRepo = getIt<PatientRepository>();

  final _chiefComplaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  Patient? _selectedPatient;
  bool _isLoadingPatients = true;

  String _selectedVisitType = 'New';
  String _selectedStatus = 'Open';
  DateTime _selectedVisitDate = DateTime.now();
  DateTime? _followUpDate;

  Visit? _loadedVisit;
  bool _didPrefillEdit = false;

  bool get _isPatientLocked => widget.initialPatientId != null;

  @override
  void initState() {
    super.initState();
    _loadPatients();

    if (widget.visitId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VisitBloc>().add(LoadVisit(widget.visitId!));
      });
    }
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _patientRepo.getAllPatients();

      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoadingPatients = false;
      });

      // Point 2: lock patient when opened from patient context.
      if (_isPatientLocked) {
        _selectPatientById(
          widget.initialPatientId!,
          fallbackName: widget.initialPatientName,
        );
      } else if (_loadedVisit != null) {
        _selectPatientById(
          _loadedVisit!.patientId,
          fallbackName: _loadedVisit!.patientName,
        );
      }
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load patients: $e')),
        );
      }
    }
  }

  void _selectPatientById(String patientId, {String? fallbackName}) {
    final match = _allPatients.where((p) => p.id == patientId).toList();
    if (match.isNotEmpty) {
      setState(() => _selectedPatient = match.first);
      return;
    }

    if (fallbackName != null && fallbackName.isNotEmpty) {
      setState(() {
        _selectedPatient = Patient(
          id: patientId,
          name: fallbackName,
          address: '',
          dateOfBirth: '',
          gender: '',
          mobileNumber: '',
          email: '',
          createdAt: DateTime.now(),
        );
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.mobileNumber.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _onAddNewPatient() async {
    final result = await GoRouter.of(context).push('${RouteNames.patients}/add');
    if (result == true) {
      await _loadPatients();
    }
  }

  Future<void> _selectVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedVisitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _selectedVisitDate = picked);
  }

  Future<void> _selectFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? _selectedVisitDate.add(const Duration(days: 7)),
      firstDate: _selectedVisitDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  void _applyLoadedVisit(Visit visit) {
    if (_didPrefillEdit) return;
    _didPrefillEdit = true;
    _loadedVisit = visit;

    _selectedVisitDate = visit.visitDate;
    _selectedVisitType = visit.visitType;
    _selectedStatus = visit.status;
    _followUpDate = visit.followUpDate;

    _chiefComplaintController.text = visit.chiefComplaint;
    _diagnosisController.text = visit.diagnosis;
    _prescriptionController.text = visit.prescription;
    _notesController.text = visit.notes;

    if (!_isPatientLocked) {
      _selectPatientById(visit.patientId, fallbackName: visit.patientName);
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPatient == null || _selectedPatient!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    final visit = Visit(
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.name,
      visitDate: _selectedVisitDate,
      visitType: _selectedVisitType,
      chiefComplaint: _chiefComplaintController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      prescription: _prescriptionController.text.trim(),
      notes: _notesController.text.trim(),
      followUpDate: _followUpDate,
      status: _selectedStatus,
      createdAt: _loadedVisit?.createdAt ?? DateTime.now(),
    );

    if (widget.visitId != null) {
      context.read<VisitBloc>().add(
        UpdateVisit(visitId: widget.visitId!, visit: visit),
      );
    } else {
      context.read<VisitBloc>().add(AddVisit(visit));
    }
  }

  Widget _buildLockedPatientTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline),
      title: Text(_selectedPatient?.name ?? widget.initialPatientName ?? ''),
      subtitle: const Text('Patient selected from patient context'),
    );
  }

  Widget _buildPatientSearchDropdown() {
    if (_isLoadingPatients) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Patient', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: _filterPatients,
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              if (_selectedPatient != null)
                ListTile(
                  title: Text(_selectedPatient!.name),
                  subtitle: Text(_selectedPatient!.mobileNumber),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedPatient = null),
                  ),
                )
              else
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final p = _filteredPatients[index];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(p.mobileNumber),
                        onTap: () => setState(() => _selectedPatient = p),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _onAddNewPatient,
          icon: const Icon(Icons.person_add),
          label: const Text('Add New Patient'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.visitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Visit' : 'Add Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: BlocConsumer<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitLoadSuccess) {
            _applyLoadedVisit(state.visit);
          } else if (state is VisitOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            GoRouter.of(context).pop(true);
          } else if (state is VisitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is VisitLoading && isEdit && !_didPrefillEdit) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_isPatientLocked) _buildLockedPatientTile() else _buildPatientSearchDropdown(),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedVisitType,
                    decoration: const InputDecoration(labelText: 'Visit Type'),
                    items: const [
                      DropdownMenuItem(value: 'New', child: Text('New')),
                      DropdownMenuItem(value: 'Follow Up', child: Text('Follow Up')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedVisitType = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Visit Date'),
                    subtitle: Text(DateFormat('EEE, MMM dd, yyyy').format(_selectedVisitDate)),
                    trailing: TextButton(
                      onPressed: _selectVisitDate,
                      child: const Text('Change'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _chiefComplaintController,
                    decoration: const InputDecoration(labelText: 'Chief Complaint'),
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter chief complaint'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(labelText: 'Diagnosis'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prescriptionController,
                    decoration: const InputDecoration(labelText: 'Prescription'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'Open', child: Text('Open')),
                      DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedStatus = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_repeat_outlined),
                    title: const Text('Follow-up Date'),
                    subtitle: Text(
                      _followUpDate == null
                          ? 'Not set'
                          : DateFormat('EEE, MMM dd, yyyy').format(_followUpDate!),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(onPressed: _selectFollowUpDate, child: const Text('Set')),
                        if (_followUpDate != null)
                          TextButton(
                            onPressed: () => setState(() => _followUpDate = null),
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is VisitLoading ? null : _onSubmit,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: state is VisitLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(isEdit ? 'Update Visit' : 'Save Visit'),
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