import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos el provider de miembros que ya tenías y el nuevo de familias
import '../../../members/data/providers/members_provider.dart';
import '../../data/providers/family_provider.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  String? selectedPadreId;
  String? selectedHijoId;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final linksAsync = ref.watch(familyLinksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vincular Pares i Fills', style: TextStyle(fontWeight: FontWeight.bold))),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al carregar membres: $err')),
        data: (members) {
          // Ordenamos alfabéticamente a todos
          final sortedMembers = List.of(members)..sort((a, b) => a.displayName.compareTo(b.displayName));

          // 🆕 FILTRAMOS POR ROLES
          final possibleParents = sortedMembers.where((m) => m.rol == 'admin' || m.rol == 'miembro').toList();
          final possibleChildren = sortedMembers.where((m) => m.rol == 'joven' || m.rol == 'nino').toList();

          return Column(
            children: [
              // --- ZONA DE CREACIÓN ---
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Nou Vincle Familiar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Selecciona el Pare / Mare', border: OutlineInputBorder()),
                      value: selectedPadreId,
                      // 👇 Usamos la lista de padres
                      items: possibleParents.map((m) => DropdownMenuItem(value: m.id, child: Text(m.displayName))).toList(),
                      onChanged: (val) => setState(() => selectedPadreId = val),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Selecciona el Fill / Filla', border: OutlineInputBorder()),
                      value: selectedHijoId,
                      // 👇 Usamos la lista de hijos
                      items: possibleChildren.map((m) => DropdownMenuItem(value: m.id, child: Text(m.displayName))).toList(),
                      onChanged: (val) => setState(() => selectedHijoId = val),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.link),
                      label: const Text('Crear Vincle'),
                      onPressed: () async {
                        if (selectedPadreId != null && selectedHijoId != null) {
                          try {
                            await ref.read(familyLinksProvider.notifier).addLink(selectedPadreId!, selectedHijoId!);
                            setState(() { selectedPadreId = null; selectedHijoId = null; });
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vincle creat correctament!')));
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                          }
                        }
                      },
                    )
                  ],
                ),
              ),

              const Divider(height: 1),

              // --- LISTA DE VÍNCULOS CREADOS ---
              Expanded(
                child: linksAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (links) {
                    if (links.isEmpty) {
                      return const Center(child: Text('Encara no hi ha cap vincle registrat.'));
                    }

                    return ListView.builder(
                      itemCount: links.length,
                      itemBuilder: (context, index) {
                        final link = links[index];
                        // Buscamos los datos reales cruzando el ID del vínculo con la lista de miembros
                        final padre = members.firstWhere((m) => m.id == link['padre_id']);
                        final hijo = members.firstWhere((m) => m.id == link['hijo_id']);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: const Icon(Icons.family_restroom, size: 20),
                          ),
                          title: Text('${padre.displayName} és pare/mare de ${hijo.displayName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(hijo.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => ref.read(familyLinksProvider.notifier).removeLink(link['id']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}