import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/clinic_service.dart';
import 'screens/login_screen.dart';
import 'screens/clinic_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Dira());
}

const Color primaryColor = Color.fromARGB(255, 67, 133, 255);
const Color secondaryColor = Color.fromARGB(255, 67, 214, 255);

class Dira extends StatelessWidget {
  const Dira({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dira',
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
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) {
          _processedUid = null;
          return const LoginScreen();
        }
        if (_processedUid != user.uid) {
          _processedUid = user.uid;
          ClinicService.ensureUserDoc();
          ClinicService.acceptPendingInvites();
        }
        return const ClinicListScreen();
      },
    );
  }
}