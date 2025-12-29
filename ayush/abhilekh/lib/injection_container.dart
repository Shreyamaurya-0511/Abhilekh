import 'package:abhilekh/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'features/attendance/data/campus_guard_service.dart';
import 'features/attendance/data/attendance_repository.dart';
import 'features/attendance/presentation/bloc/attendance_event.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // FEATURES: ATTENDANCE
  // ---------------------------------------------------------------------------
  // Bloc
  sl.registerFactory(() => AttendanceBloc(repository: sl()));
  
  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(
      firestore: sl(),
      auth: sl(),
      campusGuard: sl(),
    ),
  );

  // Data Source (Hardware Service)
  sl.registerLazySingleton(() => CampusGuardService(networkInfo: sl()));

  // ---------------------------------------------------------------------------
  // FEATURES: AUTH
  // ---------------------------------------------------------------------------
  // Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  
  // Repository
  sl.registerLazySingleton(() => AuthRepository(auth: sl(), firestore: sl()));

  // ---------------------------------------------------------------------------
  // EXTERNAL LIBRARIES
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => NetworkInfo());
}