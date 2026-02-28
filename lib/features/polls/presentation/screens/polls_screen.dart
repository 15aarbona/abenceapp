import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/models/poll_model.dart';
import '../../data/providers/poll_provider.dart';
import '../../../profile/data/providers/profile_provider.dart';

class PollsScreen extends ConsumerWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(pollsProvider);
    final isAdmin = true; // Cambiar por tu lógica real de roles

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Votacions'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Actives'),
              Tab(text: 'Passades'),
            ],
          ),
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/create-poll'),
                icon: const Icon(Icons.add),
                label: const Text('Nova'),
              )
            : null,
        body: pollsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (polls) {
            final now = DateTime.now();
            final limitPast = now.subtract(const Duration(days: 7)); // Hasta 1 semana atrás
            
            // Filtramos las encuestas
            final activePolls = polls.where((p) => p.endDate.isAfter(now)).toList();
            final pastPolls = polls.where((p) => p.endDate.isBefore(now) && p.endDate.isAfter(limitPast)).toList();

            return TabBarView(
              children: [
                _buildPollList(activePolls, 'No hi ha votacions actives.'),
                _buildPollList(pastPolls, 'No hi ha votacions recents.'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPollList(List<PollModel> list, String emptyMessage) {
    if (list.isEmpty) return Center(child: Text(emptyMessage));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => PollCard(poll: list[index]),
    );
  }
}

// --- WIDGET DE LA TARJETA DE VOTACIÓN ---
class PollCard extends ConsumerWidget {
  final PollModel poll;

  const PollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final myUserId = ref.watch(currentProfileProvider).value?.id;
    final optionsAsync = ref.watch(pollOptionsProvider(poll.id));
    final votesAsync = ref.watch(pollVotesProvider(poll.id));
    final isClosed = poll.isClosed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(poll.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Chip(
                  label: Text(isClosed ? 'Tancada' : 'Oberta'),
                  backgroundColor: isClosed ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  labelStyle: TextStyle(color: isClosed ? Colors.red : Colors.green),
                ),
              ],
            ),
            if (poll.isMultipleChoice) ...[
              const SizedBox(height: 4),
              Text('Selecció Múltiple', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            if (poll.description != null) ...[
              Text(poll.description!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
            ],
            Text('Finalitza el: ${DateFormat('dd MMM yyyy, HH:mm').format(poll.endDate)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const Divider(height: 24),

            optionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (options) {
                return votesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (votes) {
                    
                    // Ahora buscamos TODOS mis votos (por si es múltiple)
                    final myVotes = myUserId != null ? votes.where((v) => v.userId == myUserId).toList() : [];
                    final hasVoted = myVotes.isNotEmpty;
                    final isVoting = ref.watch(voteControllerProvider).isLoading;

                    // Participantes únicos
                    final totalParticipants = votes.map((v) => v.userId).toSet().length;

                    if (hasVoted || isClosed) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...options.map((option) {
                            final optionVotes = votes.where((v) => v.optionId == option.id).length;
                            // En múltiple, el % se calcula sobre el total de personas
                            final percentage = totalParticipants == 0 ? 0.0 : optionVotes / totalParticipants;
                            final isMyOption = myVotes.any((v) => v.optionId == option.id);

                            final resultWidget = Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option.text + (isMyOption ? ' (El teu vot)' : ''),
                                          style: TextStyle(fontWeight: isMyOption ? FontWeight.bold : FontWeight.normal, color: isMyOption ? theme.colorScheme.primary : null),
                                        ),
                                      ),
                                      Text('${(percentage * 100).toStringAsFixed(1)}% ($optionVotes)'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                    color: isMyOption ? theme.colorScheme.primary : Colors.grey.shade400,
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ],
                              ),
                            );

                            if (isClosed) return resultWidget;
                            // Si es única y ya es la mía, no la hago clickable
                            if (!poll.isMultipleChoice && isMyOption) return resultWidget;

                            return InkWell(
                              onTap: isVoting ? null : () => ref.read(voteControllerProvider.notifier).submitVote(poll.id, option.id, poll.isMultipleChoice),
                              borderRadius: BorderRadius.circular(10),
                              child: Opacity(opacity: isVoting ? 0.6 : 1.0, child: resultWidget),
                            );
                          }),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Participants: $totalParticipants', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (!isClosed && hasVoted)
                                Expanded(
                                  child: Text(
                                    poll.isMultipleChoice ? 'Toca qualsevol per marcar/desmarcar' : 'Toca una altra per canviar',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: OutlinedButton(
                            onPressed: isVoting ? null : () => ref.read(voteControllerProvider.notifier).submitVote(poll.id, option.id, poll.isMultipleChoice),
                            child: Text(option.text),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}