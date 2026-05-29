import 'package:flutter/material.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  // Mock data for services
  final List<Map<String, dynamic>> _services = [
    {
      'id': '1',
      'name': 'Corte Clássico',
      'description': 'Corte tradicional com tesoura e máquina.',
      'price': 55.0,
      'duration': 30, // in minutes
    },
    {
      'id': '2',
      'name': 'Corte + Barba',
      'description': 'Corte completo e alinhamento de barba com toalha quente.',
      'price': 85.0,
      'duration': 60,
    },
    {
      'id': '3',
      'name': 'Barba Tradicional',
      'description': 'Aparar, alinhar e hidratar.',
      'price': 30.0,
      'duration': 30,
    },
    {
      'id': '4',
      'name': 'Pigmentação de Barba',
      'description': 'Tingimento para cobrir falhas e fios brancos.',
      'price': 40.0,
      'duration': 45,
    },
    {
      'id': '5',
      'name': 'Sobrancelha',
      'description': 'Alinhamento com navalha.',
      'price': 15.0,
      'duration': 15,
    },
  ];

  void _showAddEditServiceDialog([Map<String, dynamic>? service]) {
    final isEditing = service != null;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainer,
          title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: service?['name'],
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: const InputDecoration(labelText: 'Nome do serviço', hintText: 'Ex: Corte Degradê'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: service?['description'],
                  style: const TextStyle(color: AppColors.onSurface),
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: service?['price']?.toString(),
                        style: const TextStyle(color: AppColors.onSurface),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: service?['duration']?.toString(),
                        style: const TextStyle(color: AppColors.onSurface),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tempo (min)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Save logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Serviço atualizado!' : 'Serviço adicionado!')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteService(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Excluir Serviço'),
        content: Text('Tem certeza que deseja excluir o serviço "$name"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onError),
            onPressed: () {
              // TODO: Delete logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Serviço excluído com sucesso.')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catálogo de Serviços'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => _showAddEditServiceDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.only(
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            top: 16,
            bottom: 80, // espaço para o FAB
          ),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final svc = _services[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon placeholder
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.content_cut, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  svc['name'],
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'R\$ ${svc['price'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            svc['description'],
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.schedule, color: AppColors.outline, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${svc['duration']} min',
                                    style: const TextStyle(color: AppColors.outline, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                    onPressed: () => _showAddEditServiceDialog(svc),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _deleteService(svc['name']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
