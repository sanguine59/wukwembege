import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../widgets/app_icon.dart';

class Brand extends StatelessWidget {
  final bool big;
  const Brand({super.key, this.big = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: big ? 72 : 52, height: big ? 72 : 52,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(big ? 22 : 16),
            boxShadow: AppShadows.blue,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: .2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(big ? 22 : 16),
                      gradient: const RadialGradient(
                        center: Alignment(0.4, -0.5),
                        radius: 0.8,
                        colors: [Colors.white, Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
              Center(child: AppIcon('store', size: big ? 38 : 28, color: Colors.white)),
            ],
          ),
        ),
        SizedBox(height: big ? 16 : 10),
        Text('wukwembege', style: TextStyle(fontWeight: FontWeight.w800, fontSize: big ? 27 : 20, letterSpacing: -0.03)),
        if (big) ...[
          const SizedBox(height: 2),
          const Text('Run food markets. Fill every stall.', style: TextStyle(fontSize: 14, color: AppColors.text3, fontWeight: FontWeight.w700)),
        ],
      ],
    );
  }
}
