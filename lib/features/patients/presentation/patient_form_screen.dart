import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/models/patient_model.dart';
import '../presentation/bloc/patient_bloc.dart';

class PatientFormScreen extends StatefulWidget {
  final String? patientId; // null for add, has value for edit

  const PatientFormScreen({super.key, this.patientId});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();

    if (widget.patientId != null) {
      // dispatch load event
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PatientBloc>().add(LoadPatient(widget.patientId!));
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.parse(_dobController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = picked.toIso8601String().split('T')[0];
    }
  }

  void _onSubmit(bool isEdit) {
    if (!_formKey.currentState!.validate()) return;

    final patient = Patient(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _selectedGender,
      mobileNumber: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (isEdit) {
      context.read<PatientBloc>().add(
        UpdatePatient(patientId: widget.patientId!, patient: patient),
      );
    } else {
      context.read<PatientBloc>().add(AddPatient(patient));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patientId != null;
    final title = isEdit ? 'Edit Patient' : 'Add Patient';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Return true to indicate the operation succeeded
            GoRouter.of(context).pop(true);
          } else if (state is PatientFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is PatientLoadSuccess) {
            final p = state.patient;
            _nameController.text = p.name;
            _addressController.text = p.address;
            _dobController.text = p.dateOfBirth;
            _selectedGender = p.gender;
            _mobileController.text = p.mobileNumber;
            _emailController.text = p.email;
          }
        },
        builder: (context, state) {
          if (state is PatientLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter patient name'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter address' : null,
                  ),
                  const SizedBox(height: 12),

                  // dob
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please select date' : null,
                  ),
                  const SizedBox(height: 12),

                  // gender
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGender = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // mobile
                  TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (v.length < 10) {
                        return 'Mobile number must be at least 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is PatientLoading
                          ? null
                          : () => _onSubmit(isEdit),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: state is PatientLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEdit ? 'Update Patient' : 'Add Patient'),
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
