import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/providers/events_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Por defecto, proponemos la fecha de mañana
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  final List<TextEditingController> _menuControllers = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Hasta 2 años vista
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 👇 AÑADE ESTO: Filtramos las opciones vacías
    final validMenuOptions = _menuControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final controller = ref.read(createEventControllerProvider.notifier);
    await controller.createEvent(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      eventDate: _selectedDate,
      location: _locationController.text.trim(),
      menuOptions: validMenuOptions, // <--- PASAMOS LAS OPCIONES
    );

    final state = ref.read(createEventControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esdeveniment creat correctament!')),
      );
      context.pop(); // Volvemos a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createEventControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nou Esdeveniment'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Títol de l\'esdeveniment',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Camp obligatori' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Selector de Fecha y Hora
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    title: const Text('Data i Hora'),
                    subtitle: Text(
                      DateFormat('EEEE, dd MMM yyyy - HH:mm', 'es').format(_selectedDate),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicació (Opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Descripció (Opcional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  
                  const SizedBox(height: 32),

                  const Text('Opcions de Menú / Tria (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(_menuControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _menuControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Opció ${index + 1}',
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _menuControllers.removeAt(index)),
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setState(() => _menuControllers.add(TextEditingController())),
                    icon: const Icon(Icons.add),
                    label: const Text('Afegir opció'),
                  ),
                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    icon: const Icon(Icons.save),
                    label: const Text('Crear Esdeveniment', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}