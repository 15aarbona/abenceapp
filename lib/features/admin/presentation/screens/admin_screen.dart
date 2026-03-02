import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/export_census_provider.dart';

// Cambiamos a ConsumerWidget para usar Riverpod
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Escuchamos el estado por si está cargando
    final exportState = ref.watch(exportCensusControllerProvider);
    final isLoadingExport = exportState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel d\'Administració', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Gestió de la Filà', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                // 1. Añadir Nuevos Miembros
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1_outlined),
                  title: const Text('Alta de Nous Membres'),
                  subtitle: const Text('Crear perfils per a la Filà'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/create-member');
                  },
                ),
                const Divider(height: 1, indent: 56),
                
                // 2. Asociar Padres e Hijos
                ListTile(
                  leading: const Icon(Icons.family_restroom_outlined),
                  title: const Text('Vincular Pares i Fills'),
                  subtitle: const Text('Gestionar unitats familiars'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/family');
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 3. Exportar Excel
                ListTile(
                  leading: isLoadingExport 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined),
                  title: const Text('Exportar Cens (Excel)'),
                  subtitle: const Text('Descarregar el llistat complet'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isLoadingExport ? null : () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generant Excel...')));
                      await ref.read(exportCensusControllerProvider.notifier).exportToExcel();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}