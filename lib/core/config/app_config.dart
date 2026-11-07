/// Réglages globaux de l'application.
class AppConfig {
  AppConfig._();

  /// Affiche les raccourcis de démonstration (ex. "le livreur accepte") qui
  /// remplacent les événements normalement fournis par Firebase.
  ///
  /// TODO : passer à `false` dès que Firebase est branché, puis supprimer
  /// les blocs `if (AppConfig.modeDemo)` du code.
  static const bool modeDemo = true;

  // --- Contacts du support ---
  // TODO : remplacer par les vrais contacts de Livo avant la publication.
  static const String telephoneSupport = '+2290165303828';
  static const String whatsappSupport = '22965303828';
  static const String emailSupport = 'joresdev@gmail.com';
}
