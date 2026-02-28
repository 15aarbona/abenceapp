import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/events/presentation/screens/create_event_screen.dart'; // <--- AÑADE ESTO

class AppTheme {
  // Definimos los colores de la Filà Abencerrajes
  // Rojo intenso, Dorado clásico, Negro
  static const Color _primary = Color(0xFFB71C1C); // Rojo sangre/festero
  static const Color _secondary = Color(0xFFD4AF37); // Dorado metálico
  static const Color _tertiary = Color(0xFF212121); // Negro suave

  static ThemeData get light {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: _primary,
        secondary: _secondary,
        tertiary: _tertiary,
      ),
      subThemesData: const FlexSubThemesData(
        interactionEffects: false,
        tintedDisabledControls: false,
        blendOnColors: false,
        useTextTheme: true,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabUseShape: true, // Botón flotante redondo
        chipRadius: 20, // Chips redondeados
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  static ThemeData get dark {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: _primary, // En modo oscuro el rojo resalta mucho
        secondary: _secondary,
        tertiary: _tertiary,
      ),
      subThemesData: const FlexSubThemesData(
        interactionEffects: false,
        tintedDisabledControls: false,
        blendOnColors: true, // Mezcla un poco de color en el fondo negro
        useTextTheme: true,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabUseShape: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }
}