import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/utilisateur.dart';

class _Notification {
  final String id;
  final String titre;
  final String message;
  final String heure;
  final IconData icone;
  final Color couleur;
  final bool lue;

  const _Notification({
    required this.id,
    required this.titre,
    required this.message,
    required this.heure,
    required this.icone,
    required this.couleur,
    this.lue = false,
  });

  _Notification copieLue() => _Notification(
        id: id,
        titre: titre,
        message: message,
        heure: heure,
        icone: icone,
        couleur: couleur,
        lue: true,
      );
}

const _notificationsClient = [
  _Notification(
    id: 'c1',
    titre: 'Mission acceptée',
    message:
        'Pascal Houngbo a accepté ta mission et se dirige vers le point de collecte.',
    heure: 'Il y a 5 min',
    icone: Icons.check_circle_rounded,
    couleur: AppColors.success,
  ),
  _Notification(
    id: 'c2',
    titre: 'Livreur arrivé',
    message: 'Ton livreur est arrivé au point de collecte.',
    heure: 'Il y a 12 min',
    icone: Icons.two_wheeler_rounded,
    couleur: AppColors.primary,
  ),
  _Notification(
    id: 'c3',
    titre: 'Paiement confirmé',
    message: 'Ton paiement de 1 300 F a bien été reçu.',
    heure: 'Hier, 18:42',
    icone: Icons.payments_rounded,
    couleur: AppColors.info,
    lue: true,
  ),
  _Notification(
    id: 'c4',
    titre: 'Bienvenue sur Livo',
    message: 'Envoie ton premier colis en quelques secondes.',
    heure: 'Il y a 3 jours',
    icone: Icons.waving_hand_rounded,
    couleur: AppColors.accent,
    lue: true,
  ),
];

const _notificationsLivreur = [
  _Notification(
    id: 'l1',
    titre: 'Nouvelle mission proposée',
    message:
        'Esther K. te propose une course de 1 200 F (3,4 km). Réponds vite !',
    heure: 'Il y a 2 min',
    icone: Icons.local_shipping_rounded,
    couleur: AppColors.statutProposee,
  ),
  _Notification(
    id: 'l2',
    titre: 'Paiement reçu',
    message: '1 200 F ont été ajoutés à ton portefeuille.',
    heure: 'Il y a 1 h',
    icone: Icons.account_balance_wallet_rounded,
    couleur: AppColors.success,
  ),
  _Notification(
    id: 'l3',
    titre: 'Nouvel avis ★★★★★',
    message: '"Très ponctuel et aimable, merci !"',
    heure: 'Hier, 17:10',
    icone: Icons.star_rounded,
    couleur: AppColors.accent,
    lue: true,
  ),
  _Notification(
    id: 'l4',
    titre: 'Document validé',
    message: 'Ton permis de conduire a été vérifié par l\'équipe Livo.',
    heure: 'Il y a 2 jours',
    icone: Icons.verified_rounded,
    couleur: AppColors.primary,
    lue: true,
  ),
];

/// Écran des notifications, commun au client et au livreur (seul le
/// contenu change selon le rôle).
///
/// TODO une fois Firebase branché : alimenter la liste depuis
/// utilisateurs/{uid}/notifications (créées par des Cloud Functions à
/// chaque changement de statut de mission), et envoyer en parallèle une
/// notification push via Firebase Cloud Messaging.
class NotificationsScreen extends StatefulWidget {
  final RoleUtilisateur role;
  const NotificationsScreen({super.key, required this.role});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(
      widget.role == RoleUtilisateur.livreur
          ? _notificationsLivreur
          : _notificationsClient,
    );
  }

  int get _nombreNonLues => _notifications.where((n) => !n.lue).length;

  void _toutMarquerLu() {
    setState(() =>
        _notifications = _notifications.map((n) => n.copieLue()).toList());
  }

  void _marquerLue(String id) {
    setState(() {
      _notifications =
          _notifications.map((n) => n.id == id ? n.copieLue() : n).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_nombreNonLues > 0)
            TextButton(
                onPressed: _toutMarquerLu, child: const Text('Tout lire')),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_off_outlined,
                            size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text('Aucune notification',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text('Tu es à jour !',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white),
                    ),
                    onDismissed: (_) => setState(() => _notifications
                        .removeWhere((n) => n.id == notification.id)),
                    child: _CarteNotification(
                      notification: notification,
                      onTap: () => _marquerLue(notification.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CarteNotification extends StatelessWidget {
  final _Notification notification;
  final VoidCallback onTap;

  const _CarteNotification({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.lue
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: notification.lue
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notification.couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(notification.icone,
                  color: notification.couleur, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.titre,
                          style: TextStyle(
                              fontWeight: notification.lue
                                  ? FontWeight.w600
                                  : FontWeight.w700),
                        ),
                      ),
                      if (!notification.lue)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                              color: AppColors.danger, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notification.message,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(notification.heure,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
