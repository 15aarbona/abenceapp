import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../../data/providers/events_provider.dart';
import '../../domain/models/event_model.dart';
import '../../../profile/data/providers/profile_provider.dart'; // Para saber si es admin
import 'event_detail_screen.dart';
import 'package:go_router/go_router.dart'; // <--- AÑADE ESTO

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Verificamos si el usuario puede crear eventos (Admin o Miembro)
    final profile = ref.watch(currentProfileProvider).value;
    final canCreate = profile?.rol != 'nino';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Esdeveniments'),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.secondary, // Dorado
            labelColor: theme.colorScheme.secondary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            tabs: const [
              Tab(text: 'Pròxims'),
              Tab(text: 'Passats'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EventsList(isPast: false), // Lista Próximos
            _EventsList(isPast: true),  // Lista Pasados
          ],
        ),
        floatingActionButton: canCreate
            ? FloatingActionButton.extended(
                onPressed: () {
                  // Cambiamos el SnackBar por la navegación
                  context.push('/create-event'); 
                },
                label: const Text('Nou'),
                icon: const Icon(Icons.add),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }
}

class _EventsList extends ConsumerWidget {
  final bool isPast;
  const _EventsList({required this.isPast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seleccionamos el provider adecuado según la pestaña
    final eventsAsync = ref.watch(isPast ? pastEventsProvider : upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPast ? Icons.history : Icons.event_busy, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  isPast ? 'No hi ha esdeveniments passats' : 'No hi ha pròxims esdeveniments',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('dd').format(event.eventDate), // Día
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy - HH:mm', 'es').format(event.eventDate), // Fecha completa
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(event.location!, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ]
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}