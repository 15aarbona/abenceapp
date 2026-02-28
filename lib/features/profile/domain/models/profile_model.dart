class ProfileModel {
  final String id;
  final String authId;
  final String nombre;
  final String apellidos;
  final String? mote;
  final String rol; // 'admin', 'miembro', 'joven', 'nino'
  final String tipoCuota; // 'full', 'media', ...
  final String? email;
  final String? avatarUrl;
  final DateTime? fechaNacimiento;
  final String? dni;         // <--- NUEVO
  final bool excedencia;

  ProfileModel({
    required this.id,
    required this.authId,
    required this.nombre,
    required this.apellidos,
    this.mote,
    required this.rol,
    required this.tipoCuota,
    this.email,
    this.avatarUrl,
    this.fechaNacimiento,
    this.dni,                // <--- NUEVO
    this.excedencia = false, // <--- NUEVOs
  });

  // Factory para convertir JSON de Supabase a Dart
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? 'Sense Nom',
      apellidos: json['apellidos'] as String? ?? '',
      mote: json['mote'] as String?,
      rol: json['rol'] as String? ?? 'miembro',
      tipoCuota: json['tipo_cuota'] as String? ?? 'full',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] != null 
          ? DateTime.parse(json['fecha_nacimiento'] as String) 
          : null,
      dni: json['dni'] as String?,                           // <--- NUEVO
      excedencia: json['excedencia'] as bool? ?? false,
    );
  }

  // Helpers útiles
  bool get isAdmin => rol == 'admin';
  bool get canVote => rol == 'admin' || rol == 'miembro';
  String get displayName => mote != null && mote!.isNotEmpty ? mote! : nombre;
}