import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../utils/service_locator.dart';
import '../../common/widgets/side_drawer.dart';
import '../data/models/visit_model.dart';
import '../data/repositories/visit_repository.dart';

class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key, this.patientId, this.patientName});
  final String? patientId;
  final String? patientName;

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  final _repo = getIt<VisitRepository>();
  late Future<List<Visit>> _futureVisits;

  @override
  void initState() {
    super.initState();
    _futureVisits = _futureVisits = widget.patientId == null
        ? _repo.getAllVisits()
        : _repo.getVisitsByPatient(widget.patientId!);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureVisits = _futureVisits = widget.patientId == null
          ? _repo.getAllVisits()
          : _repo.getVisitsByPatient(widget.patientId!);
    });
    await _futureVisits;
  }

  Future<void> _onAdd() async {
    final result = await GoRouter.of(context).push(
      widget.patientId == null
          ? '${RouteNames.visit}/add'
          : '${RouteNames.patients}/${widget.patientId}/visits/add'
          '?name=${Uri.encodeComponent(widget.patientName ?? '')}',
    );

    if (result == true) await _refresh();
  }

  Future<void> _onEdit(Visit visit) async {
    if (visit.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Visit id missing')));
      return;
    }

    final result = await GoRouter.of(
      context,
    ).push('${RouteNames.visit}/${visit.id}');
    if (result == true) await _refresh();
  }

  Future<void> _onDelete(Visit visit) async {
    if (visit.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Visit'),
        content: Text('Delete visit for "${visit.patientName}"?'),
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
        await _repo.deleteVisit(visit.id!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Visit deleted')));
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildList(List<Visit> visits) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text('No visits yet'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Visit'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: visits.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final visit = visits[index];
        final dateText = DateFormat('MMM dd, yyyy').format(visit.visitDate);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              visit.patientName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text('$dateText • ${visit.visitType}'),
                const SizedBox(height: 6),
                Text(
                  visit.chiefComplaint.isEmpty
                      ? 'No complaint added'
                      : visit.chiefComplaint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(visit.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    visit.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusColor(visit.status),
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _onEdit(visit),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _onDelete(visit),
                ),
              ],
            ),
            onTap: () => _onEdit(visit),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patientName?.isNotEmpty == true
              ? '${widget.patientName} Visits'
              : 'Visits',
        ),
      ),
      drawer: const SideDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Visit>>(
          future: _futureVisits,
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
                      Text('Failed to load visits: ${snapshot.error}'),
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

            return _buildList(snapshot.data ?? []);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        tooltip: 'Add Visit',
        child: const Icon(Icons.add),
      ),
    );
  }
}
