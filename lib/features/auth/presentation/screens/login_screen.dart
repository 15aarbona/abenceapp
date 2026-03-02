import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para los formatters
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniController = TextEditingController();
  
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _processAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favor, rellena email i contrasenya')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isLogin) {
        await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Validaciones Registro
        if (_nombreController.text.isEmpty || _apellidosController.text.isEmpty) {
          throw 'Per favor, rellena nom i cognoms';
        }
        if (_dniController.text.isEmpty) {
          throw 'Per favor, indica el teu DNI';
        }
        if (_selectedDate == null) {
          throw 'Per favor, selecciona la teua data de naixement';
        }

        // Llamada al provider con los argumentos nombrados
        await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nombre: _nombreController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          dni: _dniController.text.trim().toUpperCase(),
          fechaNacimiento: _selectedDate!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compte creat! Benvingut a la Filà')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.shield_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                _isLogin ? 'Benvingut de nou' : 'Uneix-te a la Filà',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (!_isLogin) ...[
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apellidosController,
                  decoration: const InputDecoration(labelText: 'Cognoms', border: OutlineInputBorder(), prefixIcon: Icon(Icons.people_outline)),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dniController,
                  // ESTO ES LO QUE SUSTITUYE AL ERROR:
                  inputFormatters: [UpperCaseTextFormatter()],
                  decoration: const InputDecoration(labelText: 'DNI', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Data de Naixement', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today_outlined)),
                    child: Text(_selectedDate == null ? 'Selecciona la teua data' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contrasenya', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: _processAuth,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(_isLogin ? 'Entrar' : 'Registrar-me'),
                    ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'No tens compte? Registra\'t ací' : 'Ja tens compte? Inicia sessió'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CLASE EXTRA PARA FORZAR MAYÚSCULAS ---
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}