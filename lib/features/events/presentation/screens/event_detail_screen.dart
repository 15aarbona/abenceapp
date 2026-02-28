import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/event_model.dart';
import '../../data/providers/events_provider.dart'; 
import '../../../profile/data/providers/profile_provider.dart';
import '../../data/providers/export_provider.dart';
// 🆕 Nuevos imports para leer las familias y perfiles
import '../../../admin/data/providers/family_provider.dart';
import '../../../members/data/providers/members_provider.dart';
import '../../../profile/domain/models/profile_model.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  void _showAttendDialog({
    required BuildContext context, 
    required WidgetRef ref, 
    required bool amIAlreadyRegistered,
    required List<ProfileModel> unregisteredChildren,
  }) {
    String guestName = '';
    String? selectedMenu;
    
    // Decidir la opción seleccionada por defecto
    String inscriptionType = 'guest';
    if (!amIAlreadyRegistered) {
      inscriptionType = 'me';
    } else if (unregisteredChildren.isNotEmpty) {
      inscriptionType = 'child';
    }
    
    String? selectedChildId = unregisteredChildren.isNotEmpty ? unregisteredChildren.first.id : null;

    final List<String> menuOptions = (event.options?['menu'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nova Inscripció'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- SELECTOR PRINCIPAL ---
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Per a qui és la reserva?'),
                      value: inscriptionType,
                      items: [
                        if (!amIAlreadyRegistered)
                          const DropdownMenuItem(value: 'me', child: Text('Per a mi mateix/a')),
                        if (unregisteredChildren.isNotEmpty)
                          const DropdownMenuItem(value: 'child', child: Text('Per al meu fill/a')),
                        const DropdownMenuItem(value: 'guest', child: Text('Per a un convidat extern')),
                      ],
                      onChanged: (val) => setState(() => inscriptionType = val!),
                    ),
                    const SizedBox(height: 16),

                    // --- DEPENDIENDO DE LA OPCIÓN ---
                    if (inscriptionType == 'child') ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Quin fill/a vols apuntar?'),
                        value: selectedChildId,
                        items: unregisteredChildren.map((child) {
                          return DropdownMenuItem(value: child.id, child: Text(child.displayName));
                        }).toList(),
                        onChanged: (val) => setState(() => selectedChildId = val),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (inscriptionType == 'guest') ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Nom del convidat'),
                        onChanged: (val) => guestName = val,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (menuOptions.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Tria un menú'),
                        value: selectedMenu,
                        items: menuOptions.map((menu) => DropdownMenuItem(value: menu, child: Text(menu))).toList(),
                        onChanged: (val) => setState(() => selectedMenu = val),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel·lar')),
                FilledButton(
                  onPressed: () {
                    if (inscriptionType == 'guest' && guestName.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Has d\'indicar el nom del convidat')));
                      return;
                    }
                    
                    // Identificamos el ID del hijo si se ha seleccionado esa opción
                    String? forUserId;
                    if (inscriptionType == 'child') forUserId = selectedChildId;

                    ref.read(attendEventControllerProvider.notifier).attend(
                          eventId: event.id,
                          guestName: inscriptionType == 'guest' ? guestName : null,
                          menuOption: selectedMenu,
                          forUserId: forUserId,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(attendEventControllerProvider);

    final profileState = ref.watch(currentProfileProvider);
    final myProfileId = profileState.value?.id;
    final isAdmin = profileState.value?.isAdmin ?? false;

    // 🆕 Cargamos familias y miembros en segundo plano
    final familyLinks = ref.watch(familyLinksProvider).value ?? [];
    final allMembers = ref.watch(allMembersProvider).value ?? [];

    // 🆕 Encontramos todos los hijos de este usuario
    final myChildrenIds = familyLinks
        .where((link) => link['padre_id'] == myProfileId)
        .map((link) => link['hijo_id'] as String)
        .toList();
    final myChildren = allMembers.where((m) => myChildrenIds.contains(m.id)).toList();

    final attendeesAsync = ref.watch(eventAttendeesProvider(event.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalls'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Esborrar esdeveniment?'),
                    content: const Text('Aquesta acció no es pot desfer i s\'esborraran tots els assistents apuntats.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel·lar')),
                      FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Esborrar')),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (context.mounted) Navigator.pop(context); 
                  await ref.read(deleteEventControllerProvider.notifier).deleteEvent(event.id);
                  ref.invalidate(allEventsProvider);
                  ref.invalidate(upcomingEventsProvider);
                  ref.invalidate(pastEventsProvider);
                }
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () async {
                final attendeesState = ref.read(eventAttendeesProvider(event.id));
                if (attendeesState.hasValue) {
                  await ref.read(exportEventControllerProvider.notifier).exportToExcel(event, attendeesState.value!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espera a que carregui la llista')));
                }
              },
            ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              color: theme.colorScheme.primaryContainer,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(event.title, style: theme.textTheme.headlineSmall),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(event.eventDate)}'),
                  const SizedBox(height: 8),
                  Text('Lloc: ${event.location ?? 'No especificat'}'),
                  const SizedBox(height: 16),
                  Text(event.description ?? ''),
                  const SizedBox(height: 24),
                  
                  Builder(
                    builder: (context) {
                      final attendees = attendeesAsync.value ?? [];
                      
                      // ¿Estoy yo apuntado?
                      final amIAlreadyRegistered = attendees.any((a) => a['user_id'] == myProfileId && a['guest_name'] == null);
                      
                      // ¿Qué hijos MÍOS faltan por apuntar a este evento?
                      final unregisteredChildren = myChildren.where((child) {
                        return !attendees.any((a) => a['user_id'] == child.id && a['guest_name'] == null);
                      }).toList();

                      return Center(
                        child: FilledButton.icon(
                          onPressed: () => _showAttendDialog(
                            context: context, 
                            ref: ref, 
                            amIAlreadyRegistered: amIAlreadyRegistered,
                            unregisteredChildren: unregisteredChildren,
                          ),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Nova Inscripció'),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 32),

                  const Text('Assistents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  attendeesAsync.when(
                    data: (data) {
                      if (data.isEmpty) return const Padding(padding: EdgeInsets.all(8.0), child: Text('Encara no s\'ha apuntat ningú.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)));
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final attendee = data[index];
                          final isMyRecord = attendee['user_id'] == myProfileId;
                          final isGuest = attendee['guest_name'] != null;
                          // 🆕 ¿Esta reserva pertenece a un hijo mío?
                          final isMyChildRecord = myChildrenIds.contains(attendee['user_id']);
                          
                          final menuOption = attendee['menu_option'];
                          final profileInfo = attendee['profiles'] ?? {};
                          final String fullName = isGuest 
                              ? '${attendee['guest_name']} (Convidat de ${profileInfo['nombre'] ?? 'Anònim'})'
                              : '${profileInfo['nombre'] ?? 'Anònim'} ${profileInfo['apellidos'] ?? ''}';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: const Icon(Icons.person)),
                            title: Text(fullName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isMyRecord && !isGuest) const Text('Tu', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                if (isMyChildRecord && !isGuest) const Text('El teu fill/a', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                if (menuOption != null) Text('Menú: $menuOption', style: TextStyle(color: theme.colorScheme.primary)),
                              ],
                            ),
                            
                            // 🆕 Ahora puedes borrar la reserva si eres admin, si es tuya, O si es de tu hijo
                            trailing: (isAdmin || isMyRecord || isMyChildRecord)
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Desapuntar'),
                                          content: Text('Vols esborrar l\'assistència de $fullName?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel·lar')),
                                            FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Esborrar')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) ref.read(attendEventControllerProvider.notifier).removeAttendance(attendee['id'], event.id);
                                    },
                                  )
                                : null,
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, stack) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}