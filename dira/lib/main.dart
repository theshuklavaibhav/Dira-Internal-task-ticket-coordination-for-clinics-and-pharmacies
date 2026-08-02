// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// import 'firebase_options.dart';
// import 'services/clinic_service.dart';
// import 'screens/login_screen.dart';
// import 'screens/clinic_list_screen.dart';
// import 'theme/app_theme.dart';

// import 'package:onesignal_flutter/onesignal_flutter.dart';

// import 'screens/main_shell_screen.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //   OneSignal.initialize('a0829472-f917-4c4c-90a2-d2a7c975b423');
// //   await OneSignal.Notifications.requestPermission(true);
// //   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
// //   OneSignal.Debug.setAlertLevel(OSLogLevel.none);
// //   runApp(const Dira());
// // }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.Debug.setAlertLevel(OSLogLevel.none);

//   OneSignal.initialize('a0829472-f917-4c4c-90a2-d2a7c975b423');

//   OneSignal.User.pushSubscription.addObserver((state) {
//   debugPrint("========== PUSH SUBSCRIPTION ==========");
//   debugPrint(state.current.jsonRepresentation().toString());
// });

// OneSignal.Notifications.addPermissionObserver((granted) {
//   debugPrint("Permission changed: $granted");
// });

//   final accepted =
//       await OneSignal.Notifications.requestPermission(true);

//   debugPrint("Permission accepted = $accepted");

//   runApp(const Dira());
// }

// const Color primaryColor = Color.fromARGB(255, 67, 133, 255);
// const Color secondaryColor = Color.fromARGB(255, 67, 214, 255);

// class Dira extends StatelessWidget {
//   const Dira({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Dira',
//         theme: AppTheme.light,
//         darkTheme: AppTheme.dark,
//         themeMode: ThemeMode.system,
//         home: const AuthGate(),
//     );
//   }
// }

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});
//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   String? _processedUid;

//   Future<void> _setupOneSignal(User user) async {
//     await OneSignal.login(user.uid);

//     debugPrint(
//         "Subscription ID: ${OneSignal.User.pushSubscription.id}");

//     debugPrint(
//         "Push Token: ${OneSignal.User.pushSubscription.token}");

//     debugPrint(
//         "Opted In: ${OneSignal.User.pushSubscription.optedIn}");
    
//     debugPrint(
//       "Permission = ${OneSignal.Notifications.permission}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//         final user = snapshot.data;
//         if (user == null) {
//           _processedUid = null;
//           return const LoginScreen();
//         }
//         if (_processedUid != user.uid) {
//           _processedUid = user.uid;
//           ClinicService.ensureUserDoc();
//           ClinicService.acceptPendingInvites();
//           // OneSignal.login(user.uid); // links this device to the signed-in user
//            WidgetsBinding.instance.addPostFrameCallback((_) {
//               _setupOneSignal(user);
//            });
//         }
//         // return const ClinicListScreen();
//         return const MainShellScreen();
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'services/clinic_service.dart';
import 'theme/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final token = await FirebaseMessaging.instance.getToken();

//   debugPrint("========== FIREBASE ==========");
//   debugPrint("FCM TOKEN = $token");
//   debugPrint("==============================");
//   // Enable OneSignal Debug Logs
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.Debug.setAlertLevel(OSLogLevel.none);

//   // Initialize OneSignal
//   OneSignal.initialize("a0829472-f917-4c4c-90a2-d2a7c975b423");
//   // Observe permission changes
//   OneSignal.Notifications.addPermissionObserver((granted) {
//     debugPrint("🔔 Permission changed: $granted");
//   });

//   // Observe subscription changes
//   OneSignal.User.pushSubscription.addObserver((state) {
//     debugPrint("========== PUSH SUBSCRIPTION ==========");
//     debugPrint(state.current.jsonRepresentation().toString());
//   });

//   // Request notification permission
//   final accepted =
//       await OneSignal.Notifications.requestPermission(true);

//   debugPrint("Permission accepted: $accepted");

//   runApp(const Dira());
// }


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     // Initialize Firebase
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     debugPrint("✅ Firebase initialized");

//     // Test FCM token
//     try {
//       final token = await FirebaseMessaging.instance.getToken();

//       debugPrint("========== FIREBASE ==========");
//       debugPrint("FCM TOKEN = $token");
//       debugPrint("==============================");
//     } catch (e) {
//       debugPrint("❌ Failed to get FCM Token");
//       debugPrint(e.toString());
//     }

//     // Enable OneSignal Logs
//     OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//     OneSignal.Debug.setAlertLevel(OSLogLevel.none);

//     // Initialize OneSignal
//     OneSignal.initialize("a0829472-f917-4c4c-90a2-d2a7c975b423");

//     // Permission Observer
//     OneSignal.Notifications.addPermissionObserver((granted) {
//       debugPrint("🔔 Permission changed: $granted");
//     });

//     // Push Subscription Observer
//     OneSignal.User.pushSubscription.addObserver((state) {
//       debugPrint("========== PUSH SUBSCRIPTION ==========");
//       debugPrint(state.current.jsonRepresentation().toString());
//     });

//     // Request notification permission
//     final accepted =
//         await OneSignal.Notifications.requestPermission(true);

//     debugPrint("Permission accepted: $accepted");

//     runApp(const Dira());
//   } catch (e, stackTrace) {
//     debugPrint("❌ APP STARTUP FAILED");
//     debugPrint(e.toString());
//     debugPrint(stackTrace.toString());

//     runApp(
//       MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: Text(
//               "Startup Error\n\n$e",
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ---------------- Firebase ----------------
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint("✅ Firebase initialized");

    final messaging = FirebaseMessaging.instance;

    // Request FCM permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("FCM Permission: ${settings.authorizationStatus}");

    try {
      // Delete any cached token
      await messaging.deleteToken();
      debugPrint("Old FCM token deleted");
    } catch (_) {}

    // Wait a moment
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await messaging.getToken();

      debugPrint("========== FIREBASE ==========");
      debugPrint("FCM TOKEN = $token");
      debugPrint("==============================");
    } catch (e, st) {
      debugPrint("❌ Failed to get FCM Token");
      debugPrint(e.toString());
      debugPrint(st.toString());
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint("🔄 New FCM Token: $token");
    });

    // ---------------- OneSignal ----------------
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);

    OneSignal.initialize(
      "a0829472-f917-4c4c-90a2-d2a7c975b423",
    );

    OneSignal.Notifications.addPermissionObserver((granted) {
      debugPrint("🔔 Permission changed: $granted");
    });

    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint("========== PUSH SUBSCRIPTION ==========");
      debugPrint(state.current.jsonRepresentation().toString());
    });

    final accepted =
        await OneSignal.Notifications.requestPermission(true);

    debugPrint("Permission accepted: $accepted");

    runApp(const Dira());
  } catch (e, stackTrace) {
    debugPrint("❌ APP STARTUP FAILED");
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              "Startup Error\n\n$e",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class Dira extends StatelessWidget {
  const Dira({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dira",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _processedUid;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _processedUid = null;
        return;
      }

      if (_processedUid == user.uid) {
        return;
      }

      _processedUid = user.uid;

      _initializeUser(user);
    });
  }

  // Future<void> _initializeUser(User user) async {
  //   try {
  //     // Your existing setup
  //     await ClinicService.ensureUserDoc();
  //     await ClinicService.acceptPendingInvites();

  //     // Login user to OneSignal
  //     await OneSignal.login(user.uid);

  //     debugPrint("========== ONESIGNAL STATUS ==========");

  //     debugPrint(
  //         "Subscription ID : ${OneSignal.User.pushSubscription.id}");

  //     debugPrint(
  //         "Push Token      : ${OneSignal.User.pushSubscription.token}");

  //     debugPrint(
  //         "Opted In        : ${OneSignal.User.pushSubscription.optedIn}");

  //     debugPrint(
  //         "Permission      : ${OneSignal.Notifications.permission}");


  //     debugPrint("======================================");
  //   } catch (e, stackTrace) {
  //     debugPrint("OneSignal setup failed");
  //     debugPrint(e.toString());
  //     debugPrint(stackTrace.toString());
  //   }
  // }

  Future<void> _initializeUser(User user) async {
  try {
    await ClinicService.ensureUserDoc();
    await ClinicService.acceptPendingInvites();

    await OneSignal.login(user.uid);

    // Wait for OneSignal to finish registration
    await Future.delayed(const Duration(seconds: 5));

    debugPrint("========== ONESIGNAL STATUS ==========");
    debugPrint("Subscription ID : ${OneSignal.User.pushSubscription.id}");
    debugPrint("Push Token      : ${OneSignal.User.pushSubscription.token}");
    debugPrint("Opted In        : ${OneSignal.User.pushSubscription.optedIn}");
    debugPrint("Permission      : ${OneSignal.Notifications.permission}");
    debugPrint("======================================");
  } catch (e, stackTrace) {
    debugPrint("OneSignal setup failed");
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());
  }
}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return const MainShellScreen();
      },
    );
  }
}