import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/profile.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/pills.dart';
import 'brand.dart';
import 'forgot_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final Role initialRole;
  const LoginScreen({super.key, this.initialRole = Role.organizer});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Role _role = widget.initialRole;
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _show = false;
  bool _loading = false;

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _pw.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email and password.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AppViewModel>().signIn(_email.text.trim(), _pw.text, _role);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderBar(onBack: () => Navigator.of(context).pop()),
              const SizedBox(height: 4),
              const Brand(),
              const SizedBox(height: 28),
              SegmentedControl(
                items: const ['Organizer', 'Vendor'],
                active: _role == Role.organizer ? 'Organizer' : 'Vendor',
                onChange: (v) => setState(() => _role = v == 'Organizer' ? Role.organizer : Role.vendor),
              ),
              const SizedBox(height: 20),
              Field(label: 'Email', child: AppTextInput(controller: _email, leadIcon: 'mail', placeholder: 'you@example.com')),
              const SizedBox(height: 14),
              Field(
                label: 'Password',
                child: AppTextInput(
                  controller: _pw, obscure: !_show, placeholder: 'Your password',
                  leadIcon: 'lock', trailIcon: _show ? 'eye-off' : 'eye',
                  onTrail: () => setState(() => _show = !_show),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotScreen())),
                  child: const Text('Forgot password?', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 14),
              Btn(label: _loading ? 'Signing in…' : 'Sign in', block: true, size: BtnSize.lg, onPressed: _loading ? null : _submit),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New here? ', style: TextStyle(color: AppColors.text2, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RegisterScreen(initialRole: _role))),
                    child: const Text('Create an account', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
