import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/add_appointment_screen.dart';
import '../../features/appointments/presentation/appointments_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/patients/presentation/patient_form_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/visit/presentation/add_visit_screen.dart';
import '../../features/visit/presentation/visit_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  // Call this after Firebase.initializeApp()
  static GoRouter createRouter() {
    // Create a refresh notifier that listens to auth state changes
    final authNotifier = _AuthStateNotifier();

    return GoRouter(
      initialLocation: RouteNames.splash,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final isLoggingIn = state.matchedLocation == RouteNames.login;
        final isSplash = state.matchedLocation == RouteNames.splash;

        // Allow splash screen to display (don't redirect immediately)
        if (isSplash) return null;

        // If user is null -> redirect to login
        if (user == null) {
          if (isLoggingIn) return null;
          return RouteNames.login;
        }

        // If user is logged in and trying to access login,
        // redirect to dashboard
        if (isLoggingIn) return RouteNames.dashboard;

        // User is logged in and on a valid page
        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.appointments,
          builder: (context, state) => const AppointmentsScreen(),
        ),
        GoRoute(
          path: RouteNames.patients,
          builder: (context, state) => const PatientsScreen(),
        ),
        GoRoute(
          path: RouteNames.appointments,
          builder: (context, state) => const AppointmentsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddAppointmentScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final appointmentId = state.pathParameters['id'];
                return AddAppointmentScreen(appointmentId: appointmentId);
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.patients,
          builder: (context, state) => const PatientsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const PatientFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final patientId = state.pathParameters['id'];
                return PatientFormScreen(patientId: patientId);
              },
            ),
            GoRoute(
              path: ':id/visits',
              builder: (context, state) {
                final patientId = state.pathParameters['id']!;
                final patientName = state.uri.queryParameters['name'] ?? '';
                return VisitScreen(patientId: patientId, patientName: patientName);
              },
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) {
                    final patientId = state.pathParameters['id']!;
                    final patientName = state.uri.queryParameters['name'] ?? '';
                    return AddVisitScreen(
                      initialPatientId: patientId,
                      initialPatientName: patientName,
                    );
                  },
                ),
              ]
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.visit,
          builder: (context, state) => const VisitScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddVisitScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final visitId = state.pathParameters['id'];
                return AddVisitScreen(visitId: visitId);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// Auth state notifier converts the Firebase stream into a Listenable
class _AuthStateNotifier extends ChangeNotifier {
  late final Stream<User?> _authStream;
  late final StreamSubscription<User?> _sub;

  _AuthStateNotifier() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _sub = _authStream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
