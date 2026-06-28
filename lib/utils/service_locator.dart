import 'package:get_it/get_it.dart';

import '../features/appointments/data/repositories/appointment_repository.dart';
import '../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/services/firebase_auth_service.dart';
import '../features/patients/data/repositories/patient_repository.dart';
import '../features/patients/presentation/bloc/patient_bloc.dart';
import '../features/visit/data/repositories/visit_repository.dart';
import '../features/visit/presentation/bloc/visit_bloc.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the application
void setupServiceLocator() {
  // Register Firebase Auth Service
  getIt
    ..registerSingleton<FirebaseAuthService>(FirebaseAuthService())
    // Register Auth BLoC (singleton)
    ..registerSingleton<AuthBloc>(AuthBloc(getIt<FirebaseAuthService>()))
    // Register Patient Repository
    ..registerSingleton<PatientRepository>(PatientRepository())
    ..registerSingleton<PatientBloc>(PatientBloc(getIt<PatientRepository>()))
    // Register Appointment Repository and BLoC
    ..registerSingleton<AppointmentRepository>(AppointmentRepository())
    ..registerSingleton<AppointmentBloc>(
      AppointmentBloc(getIt<AppointmentRepository>()),
    )
    ..registerSingleton<VisitRepository>(VisitRepository())
    ..registerSingleton<VisitBloc>(VisitBloc(getIt<VisitRepository>()));
}
