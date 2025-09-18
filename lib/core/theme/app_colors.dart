import 'package:flutter/material.dart';

class AppColors {
  // Cores primárias - Laranja vibrante inspirado na referência
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark = Color(0xFFE64A19);
  
  // Cores secundárias - Rosa coral complementar
  static const Color secondary = Color(0xFFFF5722);
  static const Color secondaryLight = Color(0xFFFF7043);
  static const Color secondaryDark = Color(0xFFD84315);
  
  // Cores de apoio - Paleta moderna e vibrante
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF26C6DA);
  static const Color warning = Color(0xFFFFC107);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  
  // Cores neutras - Tons mais quentes e modernos
  static const Color background = Color(0xFFFFFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F4F0);
  static const Color surfaceElevated = Color(0xFFFFFDF9);
  
  // Cores de texto - Contrastes otimizados
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSurface = Color(0xFF1A1A1A);
  
  // Cores de borda - Tons mais suaves
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderFocus = Color(0xFFFF6B35);
  
  // Cores de sombra - Sombras mais suaves
  static const Color shadow = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowStrong = Color(0x26000000);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8A65),
    ],
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFBF7),
    ],
  );
}
