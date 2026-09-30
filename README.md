# Livraison App — Guide de démarrage

## 1. Mise en route

```bash
# 1. Créer réellement le projet Flutter (cette structure est un squelette à fusionner)
flutter create --org com.tastructure livraison_app
cd livraison_app

# 2. Copier les fichiers de ce squelette (lib/, pubspec.yaml, firestore.rules)
#    par-dessus le projet généré

# 3. Installer les dépendances
flutter pub get

# 4. Connecter Firebase
firebase login
flutterfire configure
# -> génère lib/firebase_options.dart, à dé-commenter dans main.dart

# 5. Déployer les règles de sécurité Firestore
firebase deploy --only firestore:rules
```

## 2. Pourquoi cette architecture

- `core/` : rien qui dépend de Firebase ou d'un écran précis — thème, constantes, utilitaires réutilisables partout
- `data/` : tout ce qui parle à Firestore/API externes (repositories). C'est la SEULE couche qui doit importer `cloud_firestore`
- `domain/` : les objets métier purs (Mission, Utilisateur, Candidature...) sans dépendance Flutter ni Firebase
- `presentation/` : écrans et widgets, qui ne parlent jamais directement à Firestore — toujours via un provider Riverpod qui appelle un repository

Cette séparation te permet, par exemple, de changer d'agrégateur de paiement plus tard sans toucher à un seul écran.

## 3. Checklist sécurité — à ne jamais sauter

### Authentification
- [ ] Email/téléphone vérifié avant d'activer certaines actions sensibles (création de mission, retrait d'argent)
- [ ] Règle Firestore : un client ne peut modifier que son propre document `users/{userId}`
- [ ] Le rôle (`client`/`livreur`) et le statut de candidature ne sont **jamais** modifiables depuis l'app cliente — uniquement via une Cloud Function déclenchée par un admin authentifié avec un custom claim

### Données sensibles
- [ ] Pièces d'identité et permis stockés dans Firebase Storage avec des règles dédiées (lecture réservée à l'admin et au propriétaire, jamais public)
- [ ] Numéro de téléphone du destinataire jamais exposé publiquement — visible uniquement par le livreur assigné, le temps de la mission
- [ ] Position GPS en temps réel accessible uniquement au client et au livreur concernés par la mission en cours (voir `firestore.rules`, collection `positions`)

### Argent — le point le plus sensible juridiquement
- [ ] **Aucune écriture directe côté client** sur les collections `transactions` ou sur le champ `solde` d'un utilisateur — tout doit passer par une Cloud Function avec le SDK Admin, jamais par le SDK client
- [ ] Le calcul de commission se fait côté serveur (Cloud Function), jamais dans l'app Flutter — sinon un utilisateur pourrait le manipuler
- [ ] Chaque mouvement d'argent (paiement client, commission prélevée, retrait livreur) doit être journalisé avec horodatage, montant, et références — c'est ta preuve en cas de litige ou de contrôle
- [ ] Vérifier les obligations légales béninoises (déclaration d'activité, éventuel agrément si tu manies des flux financiers pour compte de tiers) — un agrégateur de paiement agréé (Kkiapay/FeexPay) t'évite d'avoir à porter cette responsabilité réglementaire toi-même, mais confirme les conditions exactes avec eux

### Général
- [ ] Ne jamais committer de clé API ou de fichier `google-services.json`/`GoogleService-Info.plist` dans un dépôt public — utiliser `.gitignore`
- [ ] Toujours valider les entrées utilisateur côté client ET recontrôler côté serveur (Cloud Function) — la validation Flutter seule ne protège de rien contre un utilisateur qui bypasserait l'app
- [ ] Limiter les tentatives de connexion (Firebase Auth le fait en partie automatiquement)
- [ ] Tester les règles Firestore avec l'émulateur avant chaque déploiement (`firebase emulators:start`)

## 4. Prochaines étapes de développement suggérées

1. Écrans d'authentification (inscription, choix de profil)
2. Formulaire de candidature livreur + upload documents
3. Cloud Functions : validation candidature, calcul tarif, gestion transactions
4. Écran client : création de mission + liste des livreurs disponibles
5. Écran livreur : réception de proposition + décompte
6. Suivi temps réel (carte + position)
7. Intégration paiement (agrégateur)
8. Panel admin (Flutter Web)
