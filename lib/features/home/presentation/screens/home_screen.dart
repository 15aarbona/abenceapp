import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../profile/data/providers/profile_provider.dart';

// --- IMPORTS DE LOS PROVIDERS Y MODELOS ---
import '../../../events/data/providers/events_provider.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../polls/data/providers/poll_provider.dart';
import '../../../polls/domain/models/poll_model.dart';
// ¡NUEVOS IMPORTS DE ANUNCIOS!
import '../../data/providers/announcement_provider.dart';
import '../../domain/models/announcement_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // --- POP-UP PARA CREAR ANUNCIOS (BOTTOM SHEET) ---
  void _showCreateAnnouncementSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para que suba con el teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          // Padding dinámico para que el teclado no tape el formulario
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nou Anunci', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Títol de l\'anunci',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripció',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Omple tots els camps')),
                      );
                      return;
                    }

                    try {
                      // Llamamos al provider para crear el anuncio
                      await ref.read(createAnnouncementControllerProvider.notifier)
                          .createAnnouncement(titleController.text, descController.text);
                      
                      if (context.mounted) {
                        Navigator.pop(context); // Cerramos el Bottom Sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Anunci publicat amb èxit!')),
                        );
                      }
                    } catch (e) {
                      // Si falla Supabase, mostramos un aviso rojo y NO cerramos el pop-up
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'), 
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Publicar Anunci'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // OBTENEMOS LOS DATOS
    final profileAsync = ref.watch(currentProfileProvider);
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final pollsAsync = ref.watch(pollsProvider);
    final announcementsAsync = ref.watch(announcementsProvider); // <-- NUEVO

    // Comprobamos si el usuario es Admin
    final isAdmin = profileAsync.value?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filà Abencerrajes', style: TextStyle(fontSize: 14)),
            profileAsync.when(
              data: (profile) => Text(
                'Hola, ${profile?.displayName ?? 'Fester'}!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              loading: () => const Text('Carregant...'),
              error: (_, __) => const Text('Hola!'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {}, // TODO: Notificaciones
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              radius: 18,
              child: profileAsync.when(
                data: (profile) => Text(
                  profile?.nombre.substring(0, 1).toUpperCase() ?? 'A',
                  style: TextStyle(color: theme.colorScheme.onSecondary),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const Icon(Icons.person),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TAULELL D'ANUNCIS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.campaign, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Taulell d\'Anuncis',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // BOTÓN DE CREAR ANUNCIO (Solo admins)
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                      onPressed: () => _showCreateAnnouncementSheet(context, ref),
                    ),
                ],
              ),
            ),
            
            announcementsAsync.when(
              data: (announcements) {
                if (announcements.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No hi ha anuncis recents.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _AnnouncementCard(announcement: announcements[index], index: index);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Error al carregar anuncis: $e'),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. PRÒXIMS ESDEVENIMENTS ---
            const _SectionHeader(title: 'Pròxims Esdeveniments', icon: Icons.calendar_today),
            upcomingEventsAsync.when(
              data: (allEvents) {
                final events = allEvents.take(4).toList();
                
                if (events.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No hi ha esdeveniments pròxims a la vista.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return SizedBox(
                  height: 140,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _EventCard(event: events[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Error al carregar esdeveniments: $e'),
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. VOTACIONS OBERTES ---
            const _SectionHeader(title: 'Votacions Obertes', icon: Icons.how_to_vote),
            pollsAsync.when(
              data: (allPolls) {
                final now = DateTime.now();
                final openPolls = allPolls.where((p) => p.endDate.isAfter(now)).take(4).toList();

                if (openPolls.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No hi ha cap votació oberta ara mateix.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return SizedBox(
                  height: 130,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: openPolls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _VotingCard(poll: openPolls[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Error al carregar votacions: $e'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        )
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends ConsumerWidget {
  final AnnouncementModel announcement;
  final int index;
  
  const _AnnouncementCard({required this.announcement, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Detectamos si es un anuncio de cumpleaños por su ID especial
    final isBirthday = announcement.id.startsWith('cumple_');
    
    // 2. Le damos un color especial a los cumples
    final bgColor = isBirthday 
        ? Colors.purple.shade800 // Color especial para cumpleaños 🎂
        : (index % 2 == 0 ? Colors.blueGrey.shade800 : Colors.brown.shade800);

    final isAdmin = ref.watch(currentProfileProvider).value?.isAdmin ?? false;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(announcement.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat("dd/MM/yyyy").format(announcement.createdAt),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  Text(
                    announcement.description,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
            actions: [
              // 3. SOLO MOSTRAMOS EL BOTÓN DE BORRAR SI ES ADMIN **Y NO ES UN CUMPLE**
              if (isAdmin && !isBirthday)
                TextButton(
                  onPressed: () async {
                    // ... (El código de confirmación de borrado se queda exactamente igual)
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Esborrar anunci?'),
                        content: const Text('Aquesta acció no es pot desfer.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel·lar'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Esborrar'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await ref.read(deleteAnnouncementControllerProvider.notifier)
                            .deleteAnnouncement(announcement.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Anunci esborrat')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Esborrar', style: TextStyle(color: Colors.red)),
                ),
                
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tancar'),
              ),
            ],
          ),
        );
      },
      // ... EL RESTO DE LA TARJETA SE QUEDA IGUAL (Stack, Icono, Textos...)
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                // Si es cumple, ponemos un icono de tarta, si no, el megáfono
                isBirthday ? Icons.cake : Icons.campaign,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      announcement.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat("dd/MM/yyyy").format(announcement.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event; 
  
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat("d MMM - HH:mm", "es_ES").format(event.eventDate);

    return InkWell(
      onTap: () {
        context.push('/event-detail', extra: event);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: theme.colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Icon(Icons.celebration, 
                    color: theme.colorScheme.onPrimaryContainer, 
                    size: 32
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    dateFormatted,
                    style: theme.textTheme.bodySmall,
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

class _VotingCard extends StatelessWidget {
  final PollModel poll; 
  
  const _VotingCard({required this.poll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final difference = poll.endDate.difference(now);
    
    String timeRemainingText;
    if (difference.inDays > 0) {
      timeRemainingText = 'Tanca en ${difference.inDays} dies';
    } else if (difference.inHours > 0) {
      timeRemainingText = 'Tanca en ${difference.inHours} hores';
    } else {
      timeRemainingText = 'Tanca en ${difference.inMinutes} min';
    }

    return InkWell(
      onTap: () {
         context.go('/votings'); 
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.secondary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  timeRemainingText,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              poll.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1.0, 
              borderRadius: BorderRadius.circular(4),
              color: theme.colorScheme.secondary.withOpacity(0.5),
              backgroundColor: theme.colorScheme.surface,
            ),
          ],
        ),
      ),
    );
  }
}