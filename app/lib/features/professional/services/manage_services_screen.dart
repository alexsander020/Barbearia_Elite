import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';
import '../../../src/core/database/firestore_service.dart';
import '../../../src/core/models/service_model.dart';

const _mockProfessionalId = 'prof_001_mock';

// Provedor para observar os serviços do profissional
final professionalServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getServices(_mockProfessionalId);
});

class ManageServicesScreen extends ConsumerStatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  ConsumerState<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends ConsumerState<ManageServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showAddEditServiceDialog([ServiceModel? service]) {
    final isEditing = service != null;
    
    if (isEditing) {
      _nameController.text = service.name;
      _descriptionController.text = service.description;
      _priceController.text = service.price.toString();
      _durationController.text = service.durationMinutes.toString();
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _durationController.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing ? 'Editar Serviço' : 'Novo Serviço',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: const InputDecoration(
                          labelText: 'Nome do serviço', 
                          hintText: 'Ex: Corte Degradê',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome do serviço';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: AppColors.onSurface),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (Opcional)',
                          hintText: 'Ex: Corte moderno na máquina e tesoura.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              style: const TextStyle(color: AppColors.onSurface),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Preço (R\$)',
                                hintText: '0.00',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o preço';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              style: const TextStyle(color: AppColors.onSurface),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tempo (min)',
                                hintText: '30',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tempo';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setDialogState(() {
                            _isLoading = true;
                          });

                          try {
                            final firestore = ref.read(firestoreServiceProvider);
                            final serviceData = ServiceModel(
                              id: isEditing ? service.id : '',
                              professionalId: _mockProfessionalId,
                              name: _nameController.text.trim(),
                              description: _descriptionController.text.trim(),
                              price: double.parse(_priceController.text),
                              durationMinutes: int.parse(_durationController.text),
                              active: true,
                            );

                            if (isEditing) {
                              await firestore.updateService(serviceData);
                            } else {
                              await firestore.createService(serviceData);
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                    isEditing ? 'Serviço atualizado com sucesso!' : 'Serviço adicionado com sucesso!',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.error,
                                content: Text('Erro ao salvar serviço: $e', style: const TextStyle(color: Colors.white)),
                              ),
                            );
                          } finally {
                            setDialogState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteService(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Excluir Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Tem certeza que deseja excluir o serviço "${service.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onError),
            onPressed: () async {
              try {
                await ref.read(firestoreServiceProvider).deleteService(service.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Serviço excluído com sucesso.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text('Erro ao excluir serviço: $e', style: const TextStyle(color: Colors.white)),
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(professionalServicesProvider);

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
        child: servicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(
            child: Text('Erro ao carregar catálogo: $err', style: const TextStyle(color: AppColors.error)),
          ),
          data: (services) {
            if (services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.content_cut, size: 64, color: AppColors.outline),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum serviço cadastrado.',
                      style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione serviços para começar a agendar.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSpacing.marginMobile,
                right: AppSpacing.marginMobile,
                top: 16,
                bottom: 80, // espaço para o FAB
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final svc = services[index];
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
                        // Icon decoration
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
                                      svc.name,
                                      style: const TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${svc.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (svc.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  svc.description,
                                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, color: AppColors.outline, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${svc.durationMinutes} min',
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
                                        onPressed: () => _deleteService(svc),
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
            );
          },
        ),
      ),
    );
  }
}
