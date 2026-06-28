// lib/features/patients/presentation/patients_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../utils/service_locator.dart';
import '../../../utils/utils.dart';
import '../../common/widgets/side_drawer.dart';
import '../../patients/data/models/patient_model.dart';
import '../../patients/data/repositories/patient_repository.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _repo = getIt<PatientRepository>();
  late Future<List<Patient>> _futurePatients;

  @override
  void initState() {
    super.initState();
    _futurePatients = _repo.getAllPatients();
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePatients = _repo.getAllPatients();
    });
    await _futurePatients;
  }

  Future<void> _onAdd() async {
    final result = await GoRouter.of(
      context,
    ).push('${RouteNames.patients}/add');
    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _onVisits(Patient patient) async {
    if (patient.id == null) return;
    final name = Uri.encodeComponent(patient.name);
    await GoRouter.of(context).push(
      '${RouteNames.patients}/${patient.id}/visits?name=$name',
    );
  }

  Future<void> _onEdit(Patient patient) async {
    if (patient.id != null) {
      final result = await GoRouter.of(
        context,
      ).push('${RouteNames.patients}/${patient.id}');
      if (result == true) {
        await _refresh();
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Patient id missing')));
    }
  }

  Future<void> _onDelete(Patient patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete patient'),
        content: Text('Are you sure you want to delete "${patient.name}"?'),
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
        await _repo.deletePatient(patient.id!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Patient deleted')));
          await _refresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  Widget _buildList(List<Patient> patients) {
    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text('No patients yet'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add patient'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: patients.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final p = patients[index];
        final age = formatAgeFromDob(p.dateOfBirth);
        final genderText = (p.gender.isNotEmpty) ? p.gender : '—';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              (p.name.isNotEmpty ? p.name[0].toUpperCase() : '?'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          title: Text(p.name),
          subtitle: Text('$genderText${age.isNotEmpty ? ' • $age' : ''}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _onEdit(p),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _onDelete(p),
              ),
              IconButton(
                tooltip: 'Visits',
                icon: const Icon(Icons.medical_services_outlined),
                onPressed: () => _onVisits(p),
              ),
            ],
          ),
          onTap: () {
            // Open edit/detail page
            _onEdit(p);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      drawer: const SideDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Patient>>(
          future: _futurePatients,
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
                      Text('Failed to load patients: ${snapshot.error}'),
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

            final patients = snapshot.data ?? [];
            return _buildList(patients);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        tooltip: 'Add Patient',
        child: const Icon(Icons.add),
      ),
    );
  }
}
