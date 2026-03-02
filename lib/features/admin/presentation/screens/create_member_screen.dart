import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/providers/create_member_provider.dart';

class CreateMemberScreen extends ConsumerStatefulWidget {
  const CreateMemberScreen({super.key});

  @override
  ConsumerState<CreateMemberScreen> createState() => _CreateMemberScreenState();
}

class _CreateMemberScreenState extends ConsumerState<CreateMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _apellidos = '';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createMemberControllerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nou Membre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crea un perfil prèvi. El membre haurà de descarregar-se l\'app i registrar-se amb aquest mateix correu per vincular el seu compte.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
                validator: (val) => val == null || val.isEmpty ? 'Camp obligatori' : null,
                onSaved: (val) => _nombre = val!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Cognoms', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
                validator: (val) => val == null || val.isEmpty ? 'Camp obligatori' : null,
                onSaved: (val) => _apellidos = val!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Correu Electrònic', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Camp obligatori';
                  if (!val.contains('@')) return 'Correu no vàlid';
                  return null;
                },
                onSaved: (val) => _email = val!,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.person_add),
                label: Text(isLoading ? 'Creant...' : 'Crear Membre'),
                onPressed: isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    try {
                      await ref.read(createMemberControllerProvider.notifier).createMember(
                        nombre: _nombre,
                        apellidos: _apellidos,
                        email: _email,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membre creat correctament!')));
                        Navigator.pop(context); // Volver atrás
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}