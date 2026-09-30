import 'package:flutter/material.dart';

/// Palette de couleurs centralisée. Ne jamais coder une couleur en dur
/// ailleurs dans l'app — toujours passer par AppColors pour garder
/// une identité visuelle cohérente et pouvoir gérer un thème sombre plus tard.
class AppColors {
  AppColors._();

  // Couleur principale — à ajuster selon l'identité de marque choisie
  static const Color primary = Color(0xFF0F6E56);      // vert profond, confiance/logistique
  static const Color primaryLight = Color(0xFF5DCAA5);
  static const Color primaryDark = Color(0xFF04342C);

  // Accent — pour les CTA secondaires, badges "nouveau", promos
  static const Color accent = Color(0xFFEF9F27);

  // États sémantiques
  static const Color success = Color(0xFF639922);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger = Color(0xFFE24B4A);
  static const Color info = Color(0xFF378ADD);

  // Statuts de mission (cohérents avec le cahier des charges)
  static const Color statutEnAttente = Color(0xFF888780);
  static const Color statutProposee = Color(0xFFEF9F27);
  static const Color statutAcceptee = Color(0xFF378ADD);
  static const Color statutEnCours = Color(0xFF0F6E56);
  static const Color statutLivree = Color(0xFF639922);
  static const Color statutAnnulee = Color(0xFFE24B4A);

  // Neutres
  static const Color background = Color(0xFFF8F9F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1A);
  static const Color textSecondary = Color(0xFF5F5E5A);
  static const Color border = Color(0xFFE2E1DA);
}
