import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../data/providers/members_provider.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('La Nostra Filà', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al carregar membres: $error')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No hi ha membres registrats encara.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // 2 columnas
              crossAxisSpacing: 16,       // Espacio horizontal
              mainAxisSpacing: 16,        // Espacio vertical
              childAspectRatio: 0.8,      // Ajuste de altura de la tarjeta
            ),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final String inicial = member.nombre.isNotEmpty ? member.nombre[0].toUpperCase() : '?';

              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar con foto o inicial
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: (member.avatarUrl != null && member.avatarUrl!.isNotEmpty)
                          ? NetworkImage(member.avatarUrl!)
                          : null,
                      child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                          ? Text(inicial, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Nombre o Mote (usando el helper de tu modelo)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        member.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Etiqueta de Rol
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.rol.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}