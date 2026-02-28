import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/providers/profile_provider.dart';
import '../../data/providers/profile_controller.dart';

import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // --- SELECCIONAR FOTO DE LA GALERÍA ---
  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Comprimimos un poco para no gastar datos
      imageQuality: 80,
    );

    if (pickedFile != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pujant foto...')));
      }
      try {
        await ref.read(profileControllerProvider.notifier).uploadAvatar(pickedFile);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto actualitzada!')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  // --- DIÁLOGOS DE EDICIÓN INDIVIDUALES ---
  void _editName(BuildContext context, WidgetRef ref, String currentName, String currentLastName) {
    final nameCtrl = TextEditingController(text: currentName);
    final lastNameCtrl = TextEditingController(text: currentLastName);
    _showEditDialog(
      context: context,
      title: 'Editar Nom i Cognoms',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: 'Cognoms', border: OutlineInputBorder())),
        ],
      ),
      onSave: () => ref.read(profileControllerProvider.notifier).updateProfile(nombre: nameCtrl.text.trim(), apellidos: lastNameCtrl.text.trim()),
    );
  }

  void _editMote(BuildContext context, WidgetRef ref, String? currentMote) {
    final moteCtrl = TextEditingController(text: currentMote ?? '');
    _showEditDialog(
      context: context,
      title: 'Editar Mote',
      content: TextField(controller: moteCtrl, decoration: const InputDecoration(labelText: 'Mote', border: OutlineInputBorder())),
      onSave: () => ref.read(profileControllerProvider.notifier).updateProfile(mote: moteCtrl.text.trim()),
    );
  }

  void _editEmail(BuildContext context, WidgetRef ref, String? currentEmail) {
    final emailCtrl = TextEditingController(text: currentEmail ?? '');
    _showEditDialog(
      context: context,
      title: 'Editar Correu Electrònic',
      content: TextField(
        controller: emailCtrl, 
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Correu', border: OutlineInputBorder())
      ),
      onSave: () => ref.read(profileControllerProvider.notifier).updateProfile(email: emailCtrl.text.trim()),
    );
  }

  // Plantilla para no repetir el código del AlertDialog
  void _showEditDialog({required BuildContext context, required String title, required Widget content, required Future<void> Function() onSave}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel·lar')),
          FilledButton(
            onPressed: () async {
              try {
                await onSave();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthday(BuildContext context, WidgetRef ref, DateTime? currentDate) async {
    final picked = await showDatePicker(
      context: context, initialDate: currentDate ?? DateTime(2000), firstDate: DateTime(1920), lastDate: DateTime.now(),
    );
    if (picked != null && picked != currentDate) {
      await ref.read(profileControllerProvider.notifier).updateProfile(fechaNacimiento: picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    ref.watch(profileControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('El Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold))),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('No s\'ha trobat el perfil'));

          final inicial = profile.nombre.isNotEmpty ? profile.nombre.substring(0, 1).toUpperCase() : '?';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- 1. CABECERA Y AVATAR ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty ? NetworkImage(profile.avatarUrl!) : null,
                          child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                              ? Text(inicial, style: TextStyle(fontSize: 45, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        // Botón flotante para editar la foto
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton.filled(
                            onPressed: () => _pickAndUploadImage(context, ref),
                            icon: const Icon(Icons.camera_alt, size: 20),
                            style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(profile.displayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. DATOS EDITABLES SEPARADOS ---
              Text('Dades Personals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nom i Cognoms', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text('${profile.nombre} ${profile.apellidos}', style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () => _editName(context, ref, profile.nombre, profile.apellidos),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Mote', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(profile.mote?.isNotEmpty == true ? profile.mote! : 'Sense mote', style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () => _editMote(context, ref, profile.mote),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Correu Electrònic', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(profile.email ?? "Sense correu", style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () => _editEmail(context, ref, profile.email),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.cake_outlined),
                      title: const Text('Data de Naixement', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        profile.fechaNacimiento != null ? DateFormat("dd/MM/yyyy", "ca_ES").format(profile.fechaNacimiento!) : 'Afegeix la teva data',
                        style: const TextStyle(fontSize: 16)
                      ),
                      trailing: const Icon(Icons.edit_calendar, size: 20),
                      onTap: () => _selectBirthday(context, ref, profile.fechaNacimiento),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. ESTADO EN LA FILÀ (Solo lectura) ---
              Text('Estat a la Filà', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('Rol'),
                      trailing: Text(profile.rol.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined),
                      title: const Text('Tipus de Quota'),
                      trailing: Text(profile.tipoCuota.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (profile.isAdmin) ...[
                Text('Administració', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Colors.orange.withOpacity(0.1), // Color distinto para que destaque
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                    title: const Text('Panel d\'Administració', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                    onTap: () => context.push('/admin'),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // --- 4. CERRAR SESIÓN ---
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Tancar Sessió', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context, builder: (context) => AlertDialog(
                        title: const Text('Tancar Sessió'),
                        content: const Text('Estàs segur que vols sortir?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel·lar')),
                          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Sortir')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(profileControllerProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}