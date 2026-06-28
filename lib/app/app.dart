import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/patients/presentation/bloc/patient_bloc.dart';
import '../features/visit/presentation/bloc/visit_bloc.dart';
import '../utils/service_locator.dart';
import 'theme/app_theme.dart';

class NiramayClinicApp extends StatelessWidget {
  final GoRouter router;

  const NiramayClinicApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => getIt<AuthBloc>()),
      BlocProvider(create: (context) => getIt<PatientBloc>()),
      BlocProvider(create: (context) => getIt<AppointmentBloc>()),
      BlocProvider(create: (context) => getIt<VisitBloc>()),
    ],

    child: MaterialApp.router(
      title: 'Niramay Clinic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    ),
  );
}
