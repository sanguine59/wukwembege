import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/profile.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/pills.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Role initialRole;
  const RegisterScreen({super.key, this.initialRole = Role.organizer});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late Role _role = widget.initialRole;
  final _name = TextEditingController();
  final _biz = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _show = false;
  bool _loading = false;

  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Please enter your full name.';
    if (_biz.text.trim().isEmpty) return 'Please enter your business name.';
    if (_email.text.trim().isEmpty) return 'Please enter your email.';
    if (_pw.text.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AppViewModel>().register(_role, _name.text.trim(), _biz.text.trim(), _email.text.trim(), _pw.text);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = _role == Role.organizer;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(title: 'Make an account', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedControl(
                      items: const ['Organizer', 'Vendor'],
                      active: isOrg ? 'Organizer' : 'Vendor',
                      onChange: (v) => setState(() => _role = v == 'Organizer' ? Role.organizer : Role.vendor),
                    ),
                    const SizedBox(height: 18),
                    Field(label: 'Full name', child: AppTextInput(controller: _name, leadIcon: 'user', placeholder: 'Your name')),
                    const SizedBox(height: 14),
                    Field(
                      label: isOrg ? 'Organization name' : 'Stall / business name',
                      child: AppTextInput(controller: _biz, leadIcon: isOrg ? 'calendar' : 'store', placeholder: isOrg ? 'e.g. Portbridge Markets Co.' : 'e.g. Lotus Dumplings'),
                    ),
                    const SizedBox(height: 14),
                    Field(label: 'Email', child: AppTextInput(controller: _email, leadIcon: 'mail', placeholder: 'you@example.com', keyboardType: TextInputType.emailAddress)),
                    const SizedBox(height: 14),
                    Field(
                      label: 'Password', hint: 'At least 8 characters.',
                      child: AppTextInput(
                        controller: _pw, obscure: !_show, leadIcon: 'lock', placeholder: 'Create a password',
                        trailIcon: _show ? 'eye-off' : 'eye',
                        onTrail: () => setState(() => _show = !_show),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Btn(label: _loading ? 'Creating…' : 'Create account', block: true, size: BtnSize.lg, onPressed: _loading ? null : _submit),
                    const SizedBox(height: 8),
                    const Text(
                      'By continuing you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.text3, height: 1.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: AppColors.text2, fontWeight: FontWeight.w700, fontSize: 13.5)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen(initialRole: _role))),
                          child: const Text('Sign in', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
