import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/user_repository.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'ui/screens/auth/onboarding_screen.dart';
import 'ui/screens/shell.dart';
import 'viewmodels/app_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  final auth = AuthRepository();
  final events = EventRepository();
  final users = UserRepository();

  runApp(WukwembegeApp(
    vm: AppViewModel(auth: auth, events: events, users: users),
  ));
}

class WukwembegeApp extends StatelessWidget {
  final AppViewModel vm;
  const WukwembegeApp({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: MaterialApp(
        title: 'wukwembege',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: Consumer<AppViewModel>(
          builder: (ctx, vm, _) {
            if (!vm.authed) return const OnboardingScreen();
            if (vm.profile == null) {
              return const Scaffold(
                backgroundColor: AppColors.canvas,
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const AppShell();
          },
        ),
      ),
    );
  }
}
