import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/providers/poll_provider.dart';

class CreatePollScreen extends ConsumerStatefulWidget {
  const CreatePollScreen({super.key});

  @override
  ConsumerState<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends ConsumerState<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  // Por defecto, la votación dura 7 días
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  bool _isMultipleChoice = false; // Añádelo debajo de tus TextEditingController

  
  // Empezamos con 2 opciones obligatorias
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];


  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
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

    // Filtramos opciones vacías
    final validOptions = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calen almenys 2 opcions vàlides.')),
      );
      return;
    }

    final controller = ref.read(createPollControllerProvider.notifier);
    await controller.createPoll(
      title: _titleController.text,
      description: _descController.text,
      endDate: _selectedDate,
      options: validOptions,
      isMultipleChoice: _isMultipleChoice,
    );

    final state = ref.read(createPollControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votació creada correctament!')),
      );
      context.pop(); // Volvemos a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createPollControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Votació'),
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
                      labelText: 'Pregunta (Ej: Quin grup portem?)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Camp obligatori' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Descripció (Opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  
                  // Selector de Fecha
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    title: const Text('Data límit per votar'),
                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 24),

                  // Lista dinámica de Opciones
                  const Text('Opcions de resposta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  
                  ...List.generate(_optionControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Opció ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'No pot estar buit' : null,
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeOption(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Afegir opció'),
                  ),

                  SwitchListTile(
                    title: const Text('Permetre selecció múltiple'),
                    subtitle: const Text('Els usuaris podran triar més d\'una opció.'),
                    value: _isMultipleChoice,
                    onChanged: (value) => setState(() => _isMultipleChoice = value),
                  ),
                  
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Crear Votació', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}