import 'package:flutter/material.dart';
import '../../../models/profile.dart';
import '../../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import 'brand.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Role? _role;

  void _go(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      (id: Role.organizer, icon: 'calendar', title: "I'm an organizer", sub: 'Run events and manage your food-stall vendors.'),
      (id: Role.vendor, icon: 'store', title: "I'm a food vendor", sub: 'Find events and book a stall in seconds.'),
    ];
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
          child: Column(
            children: [
              const Spacer(),
              const Brand(),
              const SizedBox(height: 26),
              for (final r in roles) ...[
                _RoleCard(
                  selected: _role == r.id,
                  icon: r.icon, title: r.title, sub: r.sub,
                  onTap: () => setState(() => _role = r.id),
                ),
                if (r.id != roles.last.id) const SizedBox(height: 10),
              ],
              const Spacer(),
              Btn(
                label: 'Get started',
                block: true, size: BtnSize.lg,
                disabled: _role == null,
                onPressed: _role == null ? null : () => _go(RegisterScreen(initialRole: _role!)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppColors.text2, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  GestureDetector(
                    onTap: () => _go(LoginScreen(initialRole: _role ?? Role.organizer)),
                    child: const Text('Sign in', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13.5)),
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

class _RoleCard extends StatelessWidget {
  final bool selected;
  final String icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _RoleCard({required this.selected, required this.icon, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.r),
            border: Border.all(color: selected ? AppColors.blue : AppColors.border, width: selected ? 1.5 : 1.1),
            boxShadow: selected ? [BoxShadow(color: AppColors.blueSoft, blurRadius: 0, spreadRadius: 3.5)] : AppShadows.sm,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: selected ? AppColors.blue : AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(child: AppIcon(icon, size: 24, color: selected ? Colors.white : AppColors.blue)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(color: AppColors.text3, fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.blue : Colors.transparent,
                  border: selected ? null : Border.all(color: AppColors.border, width: 2),
                ),
                child: selected ? const Center(child: AppIcon('check', size: 14, color: Colors.white)) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
