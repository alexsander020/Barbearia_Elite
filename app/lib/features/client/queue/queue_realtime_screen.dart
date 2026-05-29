import 'package:flutter/material.dart';
import '../../../src/theme/app_colors.dart';

class QueueRealtimeScreen extends StatelessWidget {
  const QueueRealtimeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Fila em Tempo Real')),
      body: const Center(child: Text('Queue — Em desenvolvimento', style: TextStyle(color: AppColors.onSurfaceVariant))),
    );
  }
}
