import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/api_client.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(title: 'Reset password', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
                child: _sent ? _sentView() : _formView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: AppIcon('lock', size: 26, color: AppColors.blue)),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            "Enter the email tied to your account and we'll send a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.55, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Field(label: 'Email', child: AppTextInput(controller: _email, leadIcon: 'mail', placeholder: 'you@example.com')),
        const SizedBox(height: 14),
        Btn(
          label: _loading ? 'Sending…' : 'Send reset link',
          block: true, size: BtnSize.lg,
          disabled: _email.text.trim().isEmpty || _loading,
          onPressed: _email.text.trim().isEmpty || _loading ? null : () async {
            setState(() => _loading = true);
            try {
              await context.read<AppViewModel>().sendPasswordReset(_email.text.trim());
              if (mounted) setState(() { _sent = true; _loading = false; });
            } catch (e) {
              if (mounted) {
                setState(() => _loading = false);
                final msg = e is ApiException ? e.message : 'Could not send reset email: $e';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _sentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(20)),
            child: const Center(child: AppIcon('check-circle', size: 32, color: AppColors.green)),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('Check your inbox', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
        const SizedBox(height: 6),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: AppColors.text2, height: 1.55, fontWeight: FontWeight.w700),
                children: [
                  const TextSpan(text: 'We sent a reset link to '),
                  TextSpan(text: _email.text, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800)),
                  const TextSpan(text: '. It expires in 30 minutes.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Btn(label: 'Back to sign in', block: true, variant: BtnVariant.outline, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
