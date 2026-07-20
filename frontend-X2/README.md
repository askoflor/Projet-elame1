# frontend-X2 — Frontend Flutter Web « ServiceConnect »

`frontend-X2` est l'application **Flutter** qui sert de frontend web à **ServiceConnect**, une plateforme de mise en relation entre clients et prestataires de services techniques (électricité, plomberie, climatisation, jardinage, peinture, etc.), avec recherche géographique, réservation, paiement mobile (Orange Money / MTN MoMo / Wave) et deux tableaux de bord dédiés (client et prestataire). La cible de déploiement principale est le **web**, packagée dans un conteneur Docker servi par Nginx ; l'application peut aussi être compilée pour Android/iOS/desktop via les dossiers de scaffolding Flutter standard, mais ce n'est pas l'usage prévu dans ce projet.

Le backend réel est un projet Spring Boot séparé (`../Backend`) qui n'expose pas encore de véritables endpoints REST : l'application tourne donc aujourd'hui avec des données et un serveur d'authentification **mockés** (voir `lib/core/config/app_config.dart`, drapeau `useMockBackend`).

## Table des matières

- [Stack & dépendances](#stack--dépendances)
- [Architecture](#architecture)
- [Arborescence détaillée](#arborescence-détaillée)
  - [lib/ — racine](#lib--racine)
  - [lib/core/](#libcore)
  - [lib/routes/](#libroutes)
  - [lib/modules/auth/](#libmodulesauth)
  - [lib/modules/home/](#libmoduleshome)
  - [lib/modules/search/](#libmodulessearch)
  - [lib/modules/booking/](#libmodulesbooking)
  - [lib/modules/payment/](#libmodulespayment)
  - [lib/modules/profile/](#libmodulesprofile)
  - [lib/modules/client/](#libmodulesclient)
  - [lib/modules/dashboard/](#libmodulesdashboard)
  - [lib/modules/provider/](#libmodulesprovider)
  - [lib/modules/historique/](#libmoduleshistorique)
  - [test/](#test)
  - [tool/](#tool)
  - [web/](#web)
  - [assets/](#assets)
  - [Fichiers de configuration et de déploiement (racine du dossier)](#fichiers-de-configuration-et-de-déploiement-racine-du-dossier)
- [Dossiers plateforme générés](#dossiers-plateforme-générés)
- [Déploiement](#déploiement)
- [Points d'attention / dette technique](#points-dattention--dette-technique)

## Stack & dépendances

Projet Flutter/Dart (`sdk: '>=3.0.0 <4.0.0'` dans `pubspec.yaml`, résolu par `pubspec.lock` avec Dart `>=3.12.0 <4.0.0` et Flutter `>=3.44.0`). `publish_to: 'none'`, version `1.0.0+1`.

Dépendances directes déclarées dans `pubspec.yaml` :

| Package | Version déclarée | Version résolue (lock) | Rôle dans le projet |
|---|---|---|---|
| `flutter` | sdk | — | SDK Flutter |
| `http` | ^1.2.0 | 1.6.0 | Client HTTP déclaré mais **non utilisé** dans le code (aucun `import 'package:http/http.dart'` trouvé) — probablement un résidu du scaffolding initial, `dio` est le client réellement utilisé |
| `dio` | ^5.4.0 | 5.9.2 | Client HTTP réellement utilisé pour tous les appels API (voir `lib/core/network/dio_client.dart`) |
| `provider` | ^6.1.1 | 6.1.5+1 | State management de l'application entière (ChangeNotifier + Provider/Consumer), utilisé pour l'auth, la traduction, l'historique de réservation et le dashboard prestataire |
| `go_router` | ^13.2.0 | 13.2.5 | Routeur déclaratif de l'application (voir `lib/routes/app_router.dart`) |
| `flutter_secure_storage` | ^9.0.0 | 9.2.4 | Stockage sécurisé du token JWT (et refresh token) côté client, avec configuration `WebOptions` pour le web |
| `shared_preferences` | ^2.2.2 | 2.5.5 | Déclarée dans les dépendances, transitive de `flutter_secure_storage`/autres ; aucun usage direct trouvé dans `lib/` |
| `flutter_svg` | ^2.0.9 | 2.3.0 | Déclarée pour le rendu de SVG, mais **aucun usage** (`SvgPicture`) trouvé dans le code actuel |
| `loading_animation_widget` | ^1.2.0+4 | 1.3.0 | Déclarée pour des animations de chargement, mais **aucun usage** trouvé dans le code actuel (les indicateurs de chargement utilisés sont des `CircularProgressIndicator` standards) |
| `google_fonts` | ^6.1.0 | 6.3.3 | Polices Google Fonts (`GoogleFonts.sora`, `GoogleFonts.dmSans`) utilisées massivement dans toute l'UI (Home, Search, Provider dashboard, etc.) |

Dépendances de développement :

| Package | Version | Rôle |
|---|---|---|
| `flutter_test` | sdk | Framework de test Flutter |
| `flutter_lints` | ^3.0.0 (résolu 3.0.2) | Règles de lint standard, activées via `analysis_options.yaml` |

Le reste de `pubspec.lock` (une quarantaine d'entrées : `async`, `collection`, `path`, `web`, `xml`, `vector_graphics*`, `path_provider*`, `shared_preferences_*`, `flutter_secure_storage_*`, `jni`/`jni_flutter`, `win32`, etc.) correspond à des dépendances **transitives** générées automatiquement par les packages ci-dessus (notamment les implémentations par plateforme de `flutter_secure_storage`, `shared_preferences`, `path_provider`, et les dépendances internes de `flutter_svg`/`google_fonts`) — elles ne sont pas listées individuellement ici.

Le `flutter: assets:` de `pubspec.yaml` déclare uniquement `assets/lang/` (les fichiers de traduction JSON).

## Architecture

Le code applicatif vit sous `lib/` et suit une architecture en **modules verticaux** avec une séparation en couches inspirée de la Clean Architecture, allégée :

```
lib/
  core/                     Code transverse partagé par tous les modules
  routes/                   Routeur applicatif (go_router)
  modules/
    <nom_du_module>/
      data/                 Sources de données : repositories (appels API réels) et/ou mocks
      domain/               Modèles/entités métier, et parfois les providers d'état (ChangeNotifier)
      presentation/
        pages/               Écrans complets (un par route)
        widgets/             Sous-composants réutilisés par les pages du module
      state/                 (optionnel) ChangeNotifier dédiés à un module complexe (provider, historique)
```

Dans le détail, ce qu'on trouve réellement dans chaque sous-couche selon les modules explorés :

- **`data/`** : contient soit un vrai repository qui appelle l'API via `DioClient` (ex. `auth/data/auth_repository.dart`), soit un simple fichier de données statiques (`mock_providers.dart`, `mock_reservations.dart`, `mock_provider_data.dart`) qui alimente l'UI en attendant un backend réel.
- **`domain/`** : classes de modèle immuables (souvent avec `copyWith`), enums de statut, et pour certains modules (`auth`, `provider`) le `ChangeNotifier` qui porte l'état applicatif est aussi placé ici plutôt que dans `state/`.
- **`presentation/pages/`** : un `StatefulWidget`/`StatelessWidget` par écran, branché sur `go_router`, qui compose les widgets de `presentation/widgets/` et consomme les providers via `context.watch`/`context.read`.
- **`presentation/widgets/`** : composants découpés par sous-section visuelle (ex. `home/presentation/widgets/hero/`, `categories/`, `providers/`, `footer/`…), souvent avec leur propre petite classe `_HoverButton` locale dupliquée d'un fichier à l'autre plutôt que factorisée.
- **`state/`** : utilisé explicitement par les modules `provider` (`provider_dashboard_state.dart`) et `historique` (`reservation_history_provider.dart`) pour leurs `ChangeNotifier`, alors que le module `auth` place son provider directement dans `domain/`. Cette convention n'est donc pas appliquée strictement partout.

La traduction (FR/EN) est gérée par un provider transverse (`core/localization/translation_provider.dart`) accessible depuis n'importe quel widget via l'extension `context.tr('clé.imbriquée')`.

## Arborescence détaillée

### lib/ — racine

- **`lib/main.dart`** — Point d'entrée réel de l'application. Initialise `WidgetsFlutterBinding`, crée un `TranslationProvider` et charge la locale `fr` par défaut, puis lance `runApp` avec un `MultiProvider` exposant `TranslationProvider`, `AuthProvider`, `ProviderDashboardProvider` et `ReservationHistoryProvider` à toute l'arborescence, avant de monter le widget racine `App`.
- **`lib/main_register.dart`** — Point d'entrée **alternatif**, non utilisé en production, qui sert de banc d'essai isolé pour l'écran d'inscription (`RegisterScreen`) : il définit son propre `GoRouter` minimal (routes `/`, `/register`, `/login`, `/dashboard` en placeholders) et son propre `MyApp`. Probablement utilisé pendant le développement via `flutter run -t lib/main_register.dart` pour itérer sur l'écran d'inscription sans lancer toute l'app.
- **`lib/app.dart`** — Définit le widget racine `App` (`StatelessWidget`) : construit le `MaterialApp.router` avec le thème (`AppTheme.lightTheme`), le titre traduit (`context.tr('app.title')`) et le `routerConfig` produit par `AppRouter.router(authProvider)`, où `authProvider` est lu via `context.watch<AuthProvider>()`.

### lib/core/

Code transverse : configuration, réseau, stockage, thème, i18n, widgets réutilisables, constantes.

- **`lib/core/config/app_config.dart`** — Configuration centrale de l'app : `baseUrl` (surchargeable au build via `--dart-define=API_BASE_URL`, défaut `http://localhost:8080`), `apiVersion` (`/api/v1`), `apiUrl` combiné, et surtout **`useMockBackend`** (`bool.fromEnvironment('USE_MOCK_BACKEND', defaultValue: true)`) — **activé par défaut** tant qu'il n'est pas explicitement désactivé au build. Déclare aussi tous les chemins d'endpoints d'auth (`/auth/login`, `/auth/register`, `/auth/logout`, `/auth/refresh`, `/auth/me`, `/auth/forgot-password`) et les timeouts réseau (30000 ms).
- **`lib/core/constants/app_constants.dart`** — Constantes globales : clés de stockage local (`auth_token`, `refresh_token`, `current_user`) et **toutes les routes** de l'application sous forme de chaînes (`/`, `/login`, `/register`, `/recherche`, `/reservation`, `/paiement`, `/profil`, `/espace-client`, `/prestataire`, `/historique`, etc.), plus quelques messages d'erreur par défaut non traduits (`loginError`, `networkError`, `serverError`).
- **`lib/core/network/dio_client.dart`** — Singleton statique `DioClient.instance` qui construit un client `Dio` configuré avec `AppConfig.apiUrl` et les timeouts, et ajoute un intercepteur qui injecte automatiquement le header `Authorization: Bearer <token>` (lu via `StorageService.getToken()`) sur chaque requête sortante.
- **`lib/core/services/storage_service.dart`** — Wrapper statique autour de `FlutterSecureStorage` (avec `WebOptions` pour la persistance web) exposant `saveToken`, `getToken`, `deleteToken`, `hasToken`, `saveRefreshToken`, `clearAll`. Toutes les opérations sont asynchrones.
- **`lib/core/theme/app_theme.dart`** — Définit la palette de couleurs de marque (`primary` bleu `#1A73E8`, `accent` vert, `error` rouge, etc.) et deux `ThemeData` (`lightTheme` très détaillé — bordures d'input, boutons — et `darkTheme` minimal, non branché nulle part dans l'app qui n'utilise que `lightTheme`).
- **`lib/core/localization/translation_provider.dart`** — `ChangeNotifier` qui charge un fichier JSON (`assets/lang/<locale>.json`) via `rootBundle`, expose `translate(key)` (résolution par chemin à points, ex. `auth.loginTitle`, avec fallback = la clé elle-même si introuvable) et `setLocale(Locale)`. Expose aussi l'extension `context.tr(key)` utilisée dans tout le projet comme raccourci de traduction.
- **`lib/core/widgets/hover_button.dart`** — Widget générique `HoverButton` (StatefulWidget) qui détecte le survol souris (`MouseRegion`) et transmet l'état `isHovered` à un `builder(context, isHovered)`, avec animation via `AnimatedContainer`. Utilisé comme brique de base pour les interactions hover, bien que de nombreux widgets du projet redéfinissent leur propre `_HoverButton` privé équivalent plutôt que de réutiliser celui-ci (duplication de code notable).
- **`lib/core/widgets/app_back_button.dart`** — Bouton de retour standardisé (`AppBackButton`), affiché en haut à gauche de quasiment tous les écrans. Par défaut appelle `context.pop()` via go_router, mais accepte un `onPressed` personnalisé.
- **`lib/core/widgets/micro_interactions.dart`** — Bibliothèque de petits widgets d'animation réutilisables : `PointerCursor` (change le curseur en pointeur sur `MouseRegion`), `HoverWrap`/`ScaleOnHover` (agrandissement au survol), `SlideOnHover` (translation au survol), `GlowOnHover` (ombre lumineuse au survol) et `StaggeredFadeIn` (apparition en cascade d'une liste d'enfants avec délai progressif). Très utilisé dans les dashboards client/prestataire et les écrans d'auth.

### lib/routes/

- **`lib/routes/app_router.dart`** — Définit `AppRouter.router(AuthProvider)`, la table de routes `GoRouter` centrale de l'application (route initiale `/`). Mappe chaque route de `AppConstants` vers son écran : accueil, login (générique + client + prestataire), inscription, mot de passe oublié, dashboard générique, recherche, réservation (avec gestion d'un `extra` qui peut être un `int` — index de service présélectionné — ou un `ProviderModel`), profil (avec `extra` optionnel `ProviderModel`), paiement, espace client, espace prestataire, historique. Le paramètre `AuthProvider` est accepté mais non utilisé pour du contrôle d'accès (pas de redirection/guard visible dans ce fichier).

### lib/modules/auth/

Module d'authentification (login, inscription, mot de passe oublié) avec deux variantes de connexion (client / prestataire) partageant la même logique.

- **`lib/modules/auth/domain/auth_model.dart`** — `UserModel` (id, email, nom, prénom, rôle, spécialité optionnelle, date de naissance optionnelle) avec `fromJson` défensif (valeurs par défaut si champs manquants), et `AuthResult` (succès/échec, token, user, message d'erreur) utilisé comme type de retour des opérations du repository.
- **`lib/modules/auth/domain/auth_provider.dart`** — `ChangeNotifier` central de l'authentification. Expose un état `AuthStatus` (`initial`, `loading`, `authenticated`, `unauthenticated`, `error`), l'utilisateur courant, un message d'erreur et un flag `isConnectionError`. Fournit `login`, `register`, `forgotPassword`, `logout`, `refreshUser`, et **`enableDemoMode(...)`** — une méthode qui **authentifie l'utilisateur localement sans appel réseau**, utilisée comme repli quand le backend est injoignable (bouton « Mode démo » affiché sur les écrans de login en cas d'erreur de connexion). Au démarrage, `_checkAuthStatus()` vérifie si un token existe déjà en stockage sécurisé.
- **`lib/modules/auth/data/auth_repository.dart`** — Repository qui appelle réellement l'API via `DioClient` (`login`, `register`, `logout`, `forgotPassword`, `getCurrentUser`), persiste le token (et refresh token si présent) via `StorageService`, et traduit les `DioException` en messages d'erreur lisibles (`_handleDioError` : timeout, 401, erreur serveur générique, erreur de connexion). C'est ce repository qui sera utilisé une fois le vrai backend Spring Boot branché (`useMockBackend = false`).
- **`lib/modules/auth/presentation/pages/login_screen.dart`** — Écran de connexion générique (route `/login`). Formulaire email/mot de passe avec validation regex, gestion d'un état de chargement, affichage d'erreurs, et un sélecteur de rôle (Client/Prestataire) pour activer le mode démo en cas d'échec réseau.
- **`lib/modules/auth/presentation/pages/client_login_screen.dart`** — Variante « client » de l'écran de connexion (route `/client-login`), redirige vers `AppConstants.clientDashboardRoute` en cas de succès ; visuellement quasi identique à `login_screen.dart` (dégradé bleu), avec un bouton mode démo pré-configuré sur le rôle `CLIENT`.
- **`lib/modules/auth/presentation/pages/provider_login_screen.dart`** — Variante « prestataire » de l'écran de connexion (route `/provider-login`), redirige vers `AppConstants.providerDashboardRoute`, thème visuel orange, mode démo pré-configuré sur le rôle `PRESTATAIRE`.
- **`lib/modules/auth/presentation/pages/register_screen.dart`** — Écran d'inscription unique gérant les deux rôles (`UserRole.client` / `UserRole.prestataire`) via un sélecteur qui change dynamiquement la palette de couleurs du formulaire. Inclut un indicateur de force du mot de passe (calcul de score sur longueur/majuscule/chiffre/caractère spécial), des champs conditionnels pour les prestataires (spécialité via dropdown, date de naissance via `showDatePicker`), et redirige vers l'écran de login correspondant au rôle après inscription réussie.
- **`lib/modules/auth/presentation/pages/forgot_password_screen.dart`** — Formulaire de demande de réinitialisation de mot de passe (email uniquement) ; affiche un écran de succès (`_buildSuccess`) une fois la demande envoyée sans erreur, avec retour vers le login.

### lib/modules/home/

Page d'accueil publique (route `/`), composée de multiples sections visuelles indépendantes.

- **`lib/modules/home/presentation/pages/home_page.dart`** — Assemble la page d'accueil complète : `NavBar`, `HeroSection`, `CategoriesSection`, `HowItWorksSection`, `PartnersSection`, `ProviderSection`, `TestimonialsSection`, `AppFooter`, dans un `SingleChildScrollView`.
- **`lib/modules/home/presentation/widgets/header/nav_bar.dart`** — Barre de navigation supérieure, responsive (bascule mobile/desktop à 768px). Affiche le logo « Service/Connect », les onglets de nav (Accueil, Recherche, Profil, Réservation, Paiement, Espace Client, Prestataire), un sélecteur de langue FR/EN branché sur `TranslationProvider`, et les boutons Connexion/Inscription (masqués si `AuthProvider.isAuthenticated`). En mobile, un menu s'ouvre via `showModalBottomSheet`. Contient sa propre classe privée `_HoverButton` (dupliquée d'autres fichiers).
- **`lib/modules/home/presentation/widgets/hero/hero_section.dart`** — Bandeau héro en dégradé bleu avec badge « disponible 24/7 », titre accrocheur (partiellement traduit, partiellement en dur en français), sous-titre, la barre de recherche (`search_bar.dart`) centrée, et une rangée de statistiques (prestataires actifs, interventions réalisées, note moyenne, temps de réponse).
- **`lib/modules/home/presentation/widgets/hero/search_bar.dart`** — Barre de recherche flottante du hero (classe `SearchBar`, qui masque le `SearchBar` Material standard — nommage à surveiller) : champs service/localisation, sélecteur de date, bouton « Trouver un prestataire » qui navigue vers `/recherche`. Textes actuellement en dur (non passés par `context.tr`).
- **`lib/modules/home/presentation/widgets/categories/categories_section.dart`** — Grille de 8 catégories de service (Électricité, Plomberie, Climatisation, Carrelage, Maintenance, Jardinage, Peinture, Menuiserie), données codées en dur dans le widget (icônes, couleurs, compteurs de prestataires factices). Le tap sur une carte navigue vers `/reservation` avec un index de service pré-sélectionné (`serviceIndexMap`).
- **`lib/modules/home/presentation/widgets/categories/category_card.dart`** — Carte individuelle de catégorie avec effet de survol (léger décalage vertical + ombre), utilisée par `categories_section.dart`.
- **`lib/modules/home/presentation/widgets/how_it_works/how_it_works_section.dart`** — Section « Comment ça marche » à 4 étapes, avec une ligne de connexion dégradée en arrière-plan derrière les puces numérotées ; contenu textuel en dur en français (non internationalisé, contrairement au titre de section).
- **`lib/modules/home/presentation/widgets/how_it_works/step_item.dart`** — Puce individuelle d'étape (cercle numéroté + titre + description), utilisée par `how_it_works_section.dart`.
- **`lib/modules/home/presentation/widgets/providers/provider_section.dart`** — Section « Prestataires populaires » avec 3 profils codés en dur (Kofi Mensah, Amara Mbaye, Fatou Diallo), affichés via `ProviderCard`, cliquables vers `/reservation`.
- **`lib/modules/home/presentation/widgets/providers/provider_card.dart`** — Carte de présentation d'un prestataire (avatar avec initiales, nom, spécialité, badge certifié, badge disponibilité, tags de compétences), avec animation de survol.
- **`lib/modules/home/presentation/widgets/partners/partners_section.dart`** — Bandeau de logos partenaires (Orange Money, MTN MoMo, Wave, Hostinger, CamTel, Afriland, Express Union) en défilement horizontal **automatique** infini, implémenté avec un `Timer.periodic` de 30 ms qui incrémente le scroll d'un `ScrollController` (liste triplée pour l'effet de boucle).
- **`lib/modules/home/presentation/widgets/testimonials/testimonials_section.dart`** — Grille de 3 témoignages clients codés en dur, affichés via `TestimonialCard`.
- **`lib/modules/home/presentation/widgets/testimonials/testimonials_card.dart`** — Carte individuelle de témoignage (avatar, nom, citation, service concerné), avec léger effet de survol.
- **`lib/modules/home/presentation/widgets/footer/app_footer.dart`** — Pied de page sombre à 4 colonnes (marque + réseaux sociaux, Services, Entreprise, Support) avec liens (certains traduits, d'autres en dur), copyright et mention de disponibilité mobile.
- **`lib/modules/home/presentation/widgets/footer/footer_hover_text.dart`** — Petit texte de lien avec effet de survol (couleur qui s'éclaircit) et navigation `go_router` optionnelle, utilisé par `app_footer.dart`.

### lib/modules/search/

Module de recherche de prestataires (route `/recherche`).

- **`lib/modules/search/domain/entities/provider_model.dart`** — Modèle `ProviderModel` (le modèle prestataire principal, réutilisé dans `booking`, `profile`) : identité, spécialité, localisation, nombre d'interventions, disponibilité, tags, note, avis, certification, prix, couleurs d'avatar, et données étendues pour la fiche profil (`about`, `skills`, `certifications`, `reviews: List<ReviewModel>`). `ReviewModel` représente un avis client individuel.
- **`lib/modules/search/data/models/mock_providers.dart`** — Jeu de données statique `mockProviders` : 10 profils de prestataires complets et réalistes (électriciens, plombiers, frigoristes, jardinier, peintre, menuisier, technicienne maintenance industrielle), avec avis et certifications détaillés. C'est la **source de données unique** utilisée par la recherche, le profil et la réservation tant qu'il n'y a pas de vrai backend.
- **`lib/modules/search/presentation/pages/search_page.dart`** — Écran de recherche : barre de recherche (`SearchBarWidget`), panneau de filtres (`FiltersPanel`), liste de résultats (`ResultCard`) générée à partir de `mockProviders`. Le nombre de résultats affiché est calculé artificiellement (`mockProviders.length * 15`). Le clic sur une carte ouvre le profil (`/profil`, `extra: provider`) ou déclenche une réservation directe (`/reservation`).
- **`lib/modules/search/presentation/widgets/map/map_widget.dart`** — Widget `MapWidget` simulant une carte interactive (fond dégradé + pins positionnés en dur avec des coordonnées pixel fixes, pas de vraie librairie de cartographie). **Non utilisé actuellement** : aucun autre fichier du projet ne l'importe (le composant existe mais n'est pas branché dans `search_page.dart`).
- **`lib/modules/search/presentation/widgets/search_bar/search_bar_widget.dart`** — Barre de recherche compacte utilisée en haut de la page de résultats (distincte de celle du hero) : champs service/localisation et boutons « Rechercher » / « Urgence », tous deux redirigeant simplement vers `/recherche`.
- **`lib/modules/search/presentation/widgets/provider_list/result_card.dart`** — Carte de résultat de recherche détaillée (avatar, badges certifié/disponibilité, tags, note/avis) avec un bouton « Réserver » dédié en plus du tap général sur la carte.
- **`lib/modules/search/presentation/widgets/filters/filters_panel.dart`** — Panneau de filtres (catégorie, disponibilité, ville via dropdown parmi 10 villes camerounaises). Les filtres sont **purement visuels** : les callbacks mettent à jour l'état local du widget (`setState`) mais ne filtrent pas réellement la liste `mockProviders` affichée dans `search_page.dart`. Une méthode `_buildUrgencyFilter` existe mais n'est appelée nulle part (code mort).

### lib/modules/booking/

Module de réservation en 4 étapes (route `/reservation`).

- **`lib/modules/booking/domain/booking_data.dart`** — Modèle de données `BookingData` transporté entre l'écran de réservation et l'écran de paiement (via `extra` de go_router) : service, prestataire, urgence, date/heure, adresse, titre/description, et un détail de coût (main-d'œuvre, déplacement, commission, total) dont les montants par défaut (10 000 / 2 000 / 600 / 12 600 FCFA) sont **codés en dur** et ne varient pas selon le service réellement choisi. Enum `PaymentMethod` (orangeMoney, mtnMoMo, wave, cash) partagé avec le module paiement.
- **`lib/modules/booking/presentation/pages/booking_page.dart`** — Écran de réservation en assistant à 4 étapes (indicateur de progression) : choix du service (grille d'icônes), description du problème + niveau d'urgence, date/créneau horaire (avec créneaux « indisponibles » codés en dur), puis choix du mode de paiement qui navigue directement vers `/paiement` avec un `BookingData` construit à partir des saisies. Accepte en paramètres optionnels un `ProviderModel` (pré-remplit le prestataire et déduit le service via `_serviceIndexForSpecialty`) ou un index de service initial.

### lib/modules/payment/

- **`lib/modules/payment/presentation/pages/payment_page.dart`** — Écran de paiement (route `/paiement`), le plus long fichier fonctionnel du projet. Récupère le `BookingData` transmis en `extra` de route. Propose 4 méthodes de paiement (Orange Money, MTN MoMo, Wave, Cash) avec formulaire de numéro de téléphone pour le mobile money, un champ code promo (non fonctionnel — affiche juste un message « invalide »), et un bouton de paiement qui simule un traitement asynchrone (`Future.delayed(2s)`) avant de générer une **référence de réservation aléatoire** (`SC-YYYYMMDD-NNNNN`) et d'appeler `ReservationHistoryProvider.ajouterReservation(...)` pour créer une nouvelle `Reservation` au statut `pending`. Affiche ensuite un écran de succès animé (`ScaleTransition` avec courbe `elasticOut`) récapitulant la réservation. Aucun appel réseau réel n'est effectué — le paiement est entièrement simulé côté client.

### lib/modules/profile/

- **`lib/modules/profile/presentation/pages/profile_screen.dart`** — Fiche de profil détaillée d'un prestataire (route `/profil`), affichée en layout deux colonnes sur desktop (≥900px) et empilé sur mobile. Reçoit un `ProviderModel` optionnel en paramètre (sinon prend `mockProviders[0]` par défaut). Sections : carte de profil (avatar, badges, stats, boutons réserver/message), à propos, compétences (chips), certifications, un calendrier de disponibilité **mensuel codé en dur** (dates et types de jour fixes indépendants du mois réel), et les avis clients (`ReviewModel` du provider).

### lib/modules/client/

- **`lib/modules/client/presentation/pages/client_dashboard_screen.dart`** — Tableau de bord de l'espace client (route `/espace-client`). Affiche un en-tête de bienvenue, une grille de 4 statistiques (interventions totales, en cours, FCFA dépensés, note moyenne — valeurs codées en dur sauf le principe de mise en forme), 3 actions rapides (trouver un prestataire, mes réservations, mes favoris), les réservations récentes lues depuis `ReservationHistoryProvider` (les 3 premières, avec état vide géré), et un bloc notifications avec 4 items dont le contenu textuel est codé en dur (traduit mais non dynamique).

### lib/modules/dashboard/

- **`lib/modules/dashboard/presentation/pages/dashboard_screen.dart`** — Écran de tableau de bord **générique/placeholder** (route `/dashboard`, distincte des dashboards client et prestataire dédiés), affichant un simple message de bienvenue et un bouton de déconnexion qui appelle `AuthProvider.logout()` puis redirige vers `/login`. Semble être un vestige du scaffolding initial, non lié depuis la nav principale.

### lib/modules/provider/

Le plus gros module de l'application : espace de gestion complet pour les prestataires (route `/prestataire`), avec sidebar de navigation interne et 8 sous-sections.

**Domaine :**

- **`lib/modules/provider/domain/provider_profile.dart`** — Modèle `ProviderProfile` : identité complète du prestataire connecté (nom, prénom, contact, spécialité, note, missions réalisées/totales, taux de satisfaction, revenu mensuel/total, adresse, compétences, description, certifications, disponibilité). Propriétés dérivées `nomComplet` et `initiales`. `copyWith` complet.
- **`lib/modules/provider/domain/mission.dart`** — Modèle `Mission` (une intervention prestataire/client) avec enum `MissionStatus` (`confirmed`, `pending`, `completed`, `cancelled`), infos client, service, créneau horaire, montant, adresse. `copyWith` complet.
- **`lib/modules/provider/domain/revenue.dart`** — Modèles `Revenue` (une transaction : montant, commission, net, statut `RevenueStatus`), `RevenueSummary` (agrégats mensuels/annuels/globaux) et `RevenueChartPoint` (point du graphique d'évolution des revenus, mois + montant + nombre de missions).
- **`lib/modules/provider/domain/notification_model.dart`** — Modèle `ProviderNotification` (titre, message, date, lu/non lu, `NotificationType` — nouvelle mission, mission annulée/complétée, paiement reçu, évaluation reçue, rappel, info) et `NotificationGroupe` (regroupement par période, bien que le regroupement effectif soit recalculé dans le widget plutôt que produit par ce modèle).
- **`lib/modules/provider/domain/planning.dart`** — Modèles de planning hebdomadaire : `PlanningSlot` (créneau avec type `PlanningSlotType` — mission/disponible/indisponible/pause), `PlanningSemaine`/`PlanningJour` (structure de la semaine), et `DisponibiliteSemaine` (horaires récurrents par jour de la semaine avec libellé `jourNom` généré).

**Data :**

- **`lib/modules/provider/data/models/mock_provider_data.dart`** — Toutes les données mockées du dashboard prestataire : un profil (`Kofi Mensah`, électricien à Abidjan), missions du jour et missions complètes (mélange de statuts, y compris passées/futures relatives à `DateTime.now()`), résumé et historique de revenus, données de graphique sur 7 mois, planning hebdomadaire généré dynamiquement (`planningSemaine`, calcule le lundi de la semaine courante), disponibilités par jour, et 7 notifications avec dates relatives. C'est la source de vérité unique consommée par `ProviderDashboardProvider`.

**State :**

- **`lib/modules/provider/state/provider_dashboard_state.dart`** — `ChangeNotifier` central du dashboard prestataire (`ProviderDashboardProvider`), instancié une fois dans `main.dart` et injecté globalement. Charge toutes les données mockées au démarrage, expose des listes filtrées par statut (`missionsEnAttente`, `missionsConfirmes`, etc.), et fournit toutes les mutations d'état : `setSelectedIndex` (onglet sidebar actif), `updateProfile`, `toggleDisponibilite`, `updateDisponibiliteJour/Heure`, `marquerNotificationLue`/`marquerToutesNotificationsLues`, `accepterMission`/`completerMission`/`annulerMission` (ces trois dernières recalculent aussi `missionsDuJour` après mutation). Toutes les mutations sont **locales en mémoire** (pas de persistance, pas d'appel réseau).

**Presentation :**

- **`lib/modules/provider/presentation/pages/provider_dashboard_screen.dart`** — Point d'entrée du dashboard prestataire. Layout desktop (sidebar fixe 240px + contenu) ou mobile (barre d'onglets horizontale scrollable en haut + contenu), bascule à 900px. Le contenu affiché dépend de `selectedIndex` du provider et route vers l'un des 8 widgets `*Content` ci-dessous.
- **`lib/modules/provider/presentation/widgets/sidebar/provider_sidebar.dart`** — Barre latérale de navigation interne : en-tête profil (avatar initiales, nom, spécialité, notation en étoiles, badge disponible/indisponible), puis les 8 items de menu (`ProviderSidebar.menuItems`, réutilisés aussi par le layout mobile de `provider_dashboard_screen.dart`) avec badge de notifications non lues sur l'item « Notifications ».
- **`lib/modules/provider/presentation/widgets/dashboard/dashboard_content.dart`** — Vue d'accueil du dashboard (index 0) : en-tête de salutation, grille de 4 métriques (nouvelles missions du jour, revenu du mois, missions réalisées, satisfaction), tableau/liste des missions du jour avec actions (accepter/annuler/compléter selon statut), et deux cartes basses (bascule disponibilité, nouvelles demandes en attente avec action d'acceptation rapide).
- **`lib/modules/provider/presentation/widgets/planning/planning_content.dart`** — Vue planning hebdomadaire (index 1) : grille de 7 jours cliquables (nombre de missions par jour), détail du jour sélectionné (missions du créneau + créneaux disponibles restants). Les boutons de navigation semaine précédente/suivante (`_buildNavButton`) sont présents visuellement mais leurs `onTap` sont des callbacks vides (`() {}`) — navigation non implémentée.
- **`lib/modules/provider/presentation/widgets/missions/missions_content.dart`** — Vue liste des missions (index 2) avec filtres par statut, recherche texte (client/service), affichage en `DataTable` sur desktop et en cartes empilées sur mobile, actions d'acceptation/annulation/complétion par ligne.
- **`lib/modules/provider/presentation/widgets/revenus/revenus_content.dart`** — Vue revenus (index 3) : 4 cartes de synthèse, un graphique en aire/courbe **dessiné à la main** via `CustomPainter` (`_ChartPainter`, dégradé de barres + courbe lissée + points) sans dépendance de charting externe, et la liste des transactions récentes avec montant net après commission.
- **`lib/modules/provider/presentation/widgets/statistiques/statistiques_content.dart`** — Vue statistiques (index 4) : 4 cartes de performance avec barres de progression (taux de succès, taux de complétion, satisfaction, note moyenne — certaines valeurs de progression sont codées en dur, ex. `0.91`, `0.78`, indépendamment des vraies données), puis une grille détaillée de 8 statistiques (dont certaines, comme « nombre de clients » à `24` ou « taux de fidélité » à `92%`, sont des valeurs fixes non calculées).
- **`lib/modules/provider/presentation/widgets/disponibilites/disponibilites_content.dart`** — Vue gestion de disponibilité (index 5) : bascule globale disponible/indisponible, puis un horaire par jour de la semaine avec `Switch` actif/inactif et sélection d'heures de début/fin via `showTimePicker` (deux appels successifs).
- **`lib/modules/provider/presentation/widgets/notifications/notifications_content.dart`** — Vue notifications (index 6) : filtre Toutes/Non lues, regroupement par période relative (« Aujourd'hui », « Hier », « Cette semaine », « Plus tôt ») calculé côté widget, marquage individuel ou global comme lu.
- **`lib/modules/provider/presentation/widgets/parametres/parametres_content.dart`** — Vue paramètres (index 7) : formulaire d'informations personnelles (persiste réellement dans `ProviderDashboardProvider.updateProfile` + `SnackBar` de confirmation), section compétences (affichage de chips avec bouton de suppression **non câblé**, champ d'ajout dont le bouton `+` a un `onTap` vide), préférences de notifications (4 switches dont les `onChanged` sont vides — état non persisté), et changement de mot de passe (formulaire sans logique de soumission réelle).

### lib/modules/historique/

Module d'historique des réservations **côté client**, partagé entre `client_dashboard_screen.dart` (aperçu) et sa propre page dédiée.

- **`lib/modules/historique/domain/reservation.dart`** — Modèle `Reservation` (référence, service, prestataire, montant, dates de réservation/intervention, créneau, adresse, description, `ReservationStatus` — pending/confirmed/completed/cancelled —, moyen de paiement, flag `annulable`), avec `formattedDate` (formatage en français) et `copyWith`.
- **`lib/modules/historique/data/models/mock_reservations.dart`** — Jeu de données statique `MockReservations` : 7 réservations avec dates relatives à `DateTime.now()` couvrant tous les statuts, plus des getters dérivés (`actives`, `terminees`, `annulees`, compteurs, `totalDepense`).
- **`lib/modules/historique/state/reservation_history_provider.dart`** — `ChangeNotifier` (`ReservationHistoryProvider`, injecté globalement depuis `main.dart`) qui charge `MockReservations.all` au démarrage puis gère l'état en mémoire : `ajouterReservation` (insertion en tête de liste, utilisée par le flux de paiement), `annulerReservation`, `confirmerReservation`, `getById`, `filtrer(query, statut)`. C'est ce provider qui reçoit les nouvelles réservations créées depuis `payment_page.dart`.
- **`lib/modules/historique/presentation/pages/historique_page.dart`** — Page dédiée à l'historique complet (route `/historique`) : en-tête avec compteurs, barre de recherche, filtres par statut (onglets), liste de `ReservationCard`, ouverture d'une bottom sheet de détail (`ReservationDetailSheet`) au tap, et dialogue de confirmation avant annulation d'une réservation annulable.
- **`lib/modules/historique/presentation/widgets/reservation_card.dart`** — Carte compacte de réservation (avatar prestataire, service, statut coloré, date/heure, montant formaté avec séparateur de milliers, bouton « Annuler » conditionnel).
- **`lib/modules/historique/presentation/widgets/reservation_detail_sheet.dart`** — Bottom sheet (`showModalBottomSheet`) de détail complet d'une réservation : toutes les informations ligne par ligne (service, date, heure, adresse, description, moyen de paiement, montant) et bouton d'annulation si applicable.

### test/

- **`test/widget_test.dart`** — Unique test du projet (test de fumée / smoke test) : monte l'`App` complète dans un `MultiProvider` minimal (`TranslationProvider` chargé en `fr`, `AuthProvider`) avec une taille d'écran forcée à 1920×1080, et vérifie simplement que le widget `App` est bien présent dans l'arbre (`find.byType(App)`). Aucun test unitaire ou de logique métier (providers, repositories, modèles) n'est présent dans le projet.

### tool/

Deux implémentations indépendantes et redondantes d'un **serveur d'authentification mock**, utilisables en développement local à la place (ou en complément) du flag `useMockBackend` côté client — elles simulent un vrai backend HTTP plutôt que de mocker les données en mémoire côté Flutter.

- **`tool/mock_server.dart`** — Serveur HTTP mock écrit en Dart pur (`dart:io HttpServer`), écoute sur `http://localhost:8080`. Implémente `/api/v1/auth/register`, `/auth/login`, `/auth/logout`, `/auth/me` avec un stockage en mémoire (`Map`) des utilisateurs et tokens, gestion CORS complète (headers + `OPTIONS`), et génération de tokens simplistes (`token-<hashCode>-<timestamp>`). Lancement via `dart run tool/mock_server.dart`.
- **`tool/mock_server.py`** — Équivalent fonctionnel **en Python** (`http.server.HTTPServer` + `BaseHTTPRequestHandler`), mêmes routes principales (register/login/logout, avec `/auth/me` géré côté `do_GET`), même logique de stockage en mémoire et CORS. Les deux scripts font sensiblement la même chose dans deux langages différents, probablement pour offrir un choix d'environnement d'exécution sans dépendre du SDK Dart.

### web/

- **`web/index.html`** — Page HTML hôte de l'app Flutter Web. Définit le `<base href>` (remplacé au build via `--base-href`), les métadonnées (description « ServiceConnect - Trouvez des professionnels de confiance pres de chez vous »), les icônes iOS/favicon, le titre d'onglet (« ServiceConnect - Plateforme de Services ») et charge `flutter_bootstrap.js` en asynchrone — c'est le template standard généré par `flutter create`, avec les métadonnées personnalisées pour la marque ServiceConnect.
- **`web/manifest.json`** — Manifeste PWA : nom `frontend_flutter` (non renommé en « ServiceConnect » — incohérence avec `index.html`), couleurs de thème bleues (`#0175C2`, couleur Flutter par défaut, non alignée avec `AppTheme.primary` `#1A73E8`), icônes standard (192/512, plus variantes maskable).
- **`web/favicon.png`, `web/icons/*.png`** — Assets d'icônes binaires standards générés par `flutter create` (non modifiés avec un branding personnalisé visible).

### assets/

- **`assets/lang/fr.json`** — Dictionnaire de traduction français, langue par défaut de l'application. Structuré en sections par domaine fonctionnel (`app`, `nav`, `hero`, `search`, `resultCard`, `auth`, `dashboard`, `categories`, `howItWorks`, `providers`, `partners`, `testimonials`, `footer`, `booking`, `client`, `profile`, `historique`, `placeholder`, `provider`). C'est le fichier de référence le plus complet (contient notamment la section `provider.*` très détaillée pour tout le dashboard prestataire).
- **`assets/lang/en.json`** — Dictionnaire de traduction anglais. **Moins complet que `fr.json`** : il manque par exemple toute la section `historique.*` (l'historique de réservation n'a donc pas de traduction anglaise et retombera sur la clé brute) ainsi que quelques clés isolées présentes côté FR (ex. `provider.colDate`, `provider.statutComplete`, `provider.voirTout`, `provider.aucuneMission` et quelques autres absentes côté EN).

### Fichiers de configuration et de déploiement (racine du dossier)

- **`Dockerfile`** — Build multi-stage : étape `build` basée sur l'image `ghcr.io/cirruslabs/flutter:stable`, qui copie `pubspec.yaml`/`pubspec.lock`, exécute `flutter pub get`, copie le reste du code puis lance `flutter build web --release` en passant `API_BASE_URL` et `USE_MOCK_BACKEND` comme `--dart-define` (arguments `ARG` avec défauts `http://localhost:8080` et `false` — **notez que le défaut Docker `USE_MOCK_BACKEND=false` diffère du défaut Dart `true`** dans `app_config.dart`, donc l'image construite sans override utilise le vrai backend). Étape `serve` : image `nginx:alpine`, copie le build web produit dans `/usr/share/nginx/html` et le fichier `nginx.conf`, expose le port 80.
- **`docker-compose.yml`** (racine de `frontend-X2`) — Compose **local au frontend seul** : un unique service `frontend` qui build l'image via le `Dockerfile` local et mappe le port hôte `8081` vers le port conteneur `80`, `restart: unless-stopped`. Distinct du `docker-compose.yml` à la racine du dépôt global (`../docker-compose.yml`) qui orchestre probablement l'ensemble backend + base de données + frontend (non détaillé ici, hors périmètre de ce README).
- **`nginx.conf`** — Configuration Nginx minimale pour servir une SPA Flutter Web : écoute sur le port 80, `root` pointant vers les fichiers buildés, `try_files $uri $uri/ /index.html` (fallback SPA), et mise en cache 30 jours sans log d'accès pour `/assets/`.
- **`pubspec.yaml`** — Manifeste du package Flutter (voir section [Stack & dépendances](#stack--dépendances) pour le détail).
- **`pubspec.lock`** — Verrouillage des versions résolues de toutes les dépendances directes et transitives (voir section [Stack & dépendances](#stack--dépendances)).
- **`analysis_options.yaml`** — Active le jeu de règles `package:flutter_lints/flutter.yaml` sans aucune règle additionnelle ni désactivée (la section `rules:` est vide, les exemples en commentaire ne sont pas décommentés) — configuration de lint par défaut du scaffolding Flutter, non personnalisée pour ce projet.
- **`.dockerignore`** — Exclut du contexte de build Docker : `.dart_tool/`, `.idea/`, `.vscode/`, `.git/`, `.gitignore`, `build/`, `coverage/`, les dossiers de plateformes natives (`android/`, `ios/`, `linux/`, `macos/`, `windows/`) puisqu'ils sont inutiles pour un build web, `test/`, les fichiers `*.log`/`*.iml`, `serve_app.ps1` et `README.md`.
- **`.gitignore`** — Fichier `.gitignore` standard généré par `flutter create` (build artifacts, `.dart_tool/`, `.idea/`, fichiers de symbolication/obfuscation, dossiers de build Android). Le bloc `.vscode/` est commenté (donc suivi par défaut) comme le recommande le template Flutter standard.
- **`serve_app.ps1`** — Script PowerShell utilitaire pour servir localement le build web déjà généré (`build/web`) via `npx serve`, sur un port passé en paramètre (défaut `8080`). **Contient un chemin absolu codé en dur** (`C:\Users\ngounou tomy\Downloads\frontend-tmp\build\web`) qui correspond à la machine d'un autre développeur et ne fonctionnera pas tel quel sur un autre poste — script à adapter localement avant usage.
- **`.flutter-plugins-dependencies`** — Fichier **généré automatiquement** par la tool­chain Flutter (`flutter pub get`) qui décrit le graphe des plugins natifs par plateforme (ex. `flutter_secure_storage`, `path_provider`, `shared_preferences` et leurs variantes par OS) ; ne doit pas être édité à la main et est habituellement régénéré à chaque `pub get`.
- **`.vscode/settings.json`** — Configuration VS Code du dépôt, ne contient qu'une entrée `cmake.sourceDirectory` pointant vers `linux/flutter`, avec là aussi un **chemin absolu codé en dur** propre à une machine de développement (`C:/Users/ngounou tomy/Downloads/frontend-tmp/linux/flutter`), sans rapport direct avec le développement Flutter/Dart quotidien (utile seulement si on compile la cible Linux).
- **`frontend_flutter.iml`** — Fichier de module IntelliJ/Android Studio généré automatiquement, déclare `lib/` comme source et `test/` comme source de test, exclut `.dart_tool/`, `.idea/`, `build/`. Fichier d'IDE, pas destiné à être maintenu manuellement.
- **`flutter_01.log`, `flutter_02.log`, `flutter_err.log`, `flutter_out.log`, `flutter_run.log`, `flutter_run_err.log`** — Journaux de sessions `flutter run`/`flutter build` laissés à la racine du dépôt (probablement générés lors du debug local). Ils sont exclus de Git via le pattern `*.log` de `.gitignore` mais restent présents sur le disque ; sans intérêt pour la compréhension du projet et peuvent être supprimés sans risque.

## Dossiers plateforme générés

Les dossiers **`android/`, `ios/`, `linux/`, `macos/`, `windows/`** (et le contenu binaire d'icônes sous **`web/icons/`**) sont des projets natifs **auto-générés par `flutter create` / `flutter build`** : ils contiennent le scaffolding standard nécessaire pour compiler l'application sur chaque plateforme (fichiers Gradle/manifest Android, projet Xcode iOS/macOS, CMake pour Linux/Windows, launcher C++/Swift/Kotlin, icônes par résolution, fichiers `.gitignore` par plateforme). Ils ne sont **pas documentés fichier par fichier** dans ce README car ils ne contiennent quasiment aucune logique métier spécifique au projet.

Dans ce projet, **la cible de déploiement réelle est le web** (voir `Dockerfile` et `nginx.conf` ci-dessus) — les dossiers natifs ne sont pas utilisés en production.

Éléments de personnalisation repérés lors d'une inspection rapide (le reste étant la configuration par défaut de `flutter create`) :

- **`android/app/src/main/AndroidManifest.xml`** : label d'application `frontend_flutter` (non renommé « ServiceConnect »), une seule activité standard (`MainActivity`), aucune permission particulière déclarée (seule la `<queries>` standard pour `ACTION_PROCESS_TEXT`, ajoutée automatiquement par le plugin texte de Flutter). Rien de notable côté package name dans ce fichier (à vérifier côté `build.gradle` si un identifiant d'application spécifique est nécessaire, non inspecté ici).
- **`macos/Runner/DebugProfile.entitlements`** et **`Release.entitlements`** : entitlements standards du template macOS (`app-sandbox` actif, `network.server` et `allow-jit` autorisés en debug uniquement) — pas de permission système additionnelle (caméra, contacts, etc.) ajoutée pour ce projet.

Le fichier interne `.metadata` à la racine (non détaillé plus avant) est un fichier généré et maintenu automatiquement par les outils Flutter pour le suivi de version du SDK ; il ne doit pas être édité manuellement.

## Déploiement

Le déploiement repose sur un **build Docker multi-stage** :

1. **Étape `build`** : image `ghcr.io/cirruslabs/flutter:stable`, installation des dépendances (`flutter pub get`), puis `flutter build web --release` avec deux variables injectées via `--dart-define` :
   - `API_BASE_URL` : URL du backend Spring Boot (ex. `https://mon-vps:8080`), lue par `AppConfig.baseUrl`.
   - `USE_MOCK_BACKEND` : active/désactive le mode mock côté client, lu par `AppConfig.useMockBackend`.
2. **Étape `serve`** : image `nginx:alpine`, qui sert les fichiers statiques produits (`build/web`) en SPA via `nginx.conf` (fallback vers `index.html` pour toutes les routes non-fichier, cohérent avec le routage côté client `go_router`), sur le port 80 du conteneur.

Le `docker-compose.yml` présent dans **ce dossier** (`frontend-X2/docker-compose.yml`) ne construit que le service frontend seul, exposé sur le port hôte `8081`. Il existe par ailleurs, à la racine du dépôt global du projet, un **`docker-compose.yml` d'orchestration** (`../docker-compose.yml`, hors du périmètre de `frontend-X2`) qui a vocation à démarrer ensemble le backend Spring Boot, la base de données et ce frontend — il n'est pas détaillé dans ce document.

En résumé, pour un déploiement pointant vers un vrai backend :

```
docker build --build-arg API_BASE_URL=https://api.mondomaine.com \
              --build-arg USE_MOCK_BACKEND=false \
              -t serviceconnect-frontend .
docker run -p 8081:80 serviceconnect-frontend
```

## Points d'attention / dette technique

Constats factuels relevés en lisant le code, sans jugement de valeur :

- **Backend mocké par défaut côté Dart** : `AppConfig.useMockBackend` a pour valeur par défaut `true` (`bool.fromEnvironment` sans override), alors que le `Dockerfile` a lui pour défaut `USE_MOCK_BACKEND=false` — les deux défauts divergent selon qu'on lance l'app en dev (`flutter run`, mock activé) ou qu'on build l'image Docker sans argument explicite (mock désactivé, donc l'app tentera de contacter un vrai backend qui n'a pas encore d'endpoints implémentés).
- **Backend Spring Boot non branché** : le repository réel (`auth/data/auth_repository.dart`) existe et est fonctionnel côté client, mais le projet `../Backend` n'expose pas encore de vrais endpoints REST — d'où la présence des deux serveurs mocks dans `tool/` et du mode démo (`AuthProvider.enableDemoMode`) comme filet de secours dans l'UI.
- **Deux implémentations redondantes de serveur mock** (`tool/mock_server.dart` et `tool/mock_server.py`) qui font la même chose dans deux langages différents ; aucune n'est référencée par un script `npm`/`Makefile`/tâche VS Code centralisé, l'usage se fait manuellement.
- **Dépendances déclarées mais non utilisées** : `http`, `flutter_svg` et `loading_animation_widget` sont présentes dans `pubspec.yaml` sans qu'aucun `import` correspondant n'apparaisse dans `lib/` (recherché explicitement) — poids mort dans le bundle et la surface de dépendances.
- **`shared_preferences` déclarée en dépendance directe** sans usage direct trouvé dans `lib/` (uniquement consommée indirectement en tant que dépendance transitive d'autres packages).
- **`MapWidget`** (`search/presentation/widgets/map/map_widget.dart`) est un composant complet mais **non branché** dans `search_page.dart` — la « carte interactive » qu'il simule n'est actuellement visible nulle part dans l'app.
- **Filtres de recherche non fonctionnels** : `FiltersPanel` met à jour son état visuel local mais ne filtre pas réellement `mockProviders` affichés dans `search_page.dart` ; une méthode `_buildUrgencyFilter` y est même définie sans jamais être appelée.
- **Boutons/actions non câblés repérés dans le dashboard prestataire** : navigation semaine précédente/suivante du planning (`planning_content.dart`, callbacks vides), suppression de compétence et ajout de compétence (`parametres_content.dart`), switches de préférences de notification (`parametres_content.dart`), et le formulaire de changement de mot de passe (aucune soumission réelle).
- **Traductions incomplètes en anglais** : `assets/lang/en.json` ne couvre pas la section `historique.*` (absente) et quelques clés isolées de la section `provider.*`, contrairement à `assets/lang/fr.json` qui est la version de référence la plus complète.
- **Textes en dur non internationalisés** par endroits malgré l'infrastructure i18n en place : `hero_section.dart` (titre/sous-titre), `search_bar.dart` du hero, `how_it_works_section.dart` (titres/descriptions d'étapes), `payment_page.dart` (la quasi-totalité des libellés), une partie de `app_footer.dart`.
- **Données majoritairement statiques/mockées** dans presque tous les modules métier (`mock_providers.dart`, `mock_reservations.dart`, `mock_provider_data.dart`) : les statistiques affichées dans les dashboards (client et prestataire) mêlent des valeurs réellement dérivées de l'état (ex. compteurs de missions par statut) et des valeurs entièrement codées en dur (ex. « 24 clients », « 92% fidélité », largeurs de barres de progression fixes dans `statistiques_content.dart`).
- **Duplication de petits widgets utilitaires** : de nombreux fichiers de `home/presentation/widgets/*` et `search/presentation/widgets/*` redéfinissent leur propre classe privée `_HoverButton` quasi identique plutôt que de réutiliser `core/widgets/hover_button.dart`.
- **Paiement et réservation entièrement simulés côté client** : `payment_page.dart` ne fait aucun appel réseau réel — le succès du paiement est garanti après un simple délai artificiel de 2 secondes, et la référence de réservation est générée aléatoirement côté client.
- **Fichiers avec chemins absolus propres à une machine de développeur** : `serve_app.ps1` et `.vscode/settings.json` contiennent tous deux un chemin `C:\Users\ngounou tomy\Downloads\frontend-tmp\...` qui ne correspond pas à l'environnement d'un autre développeur clonant le dépôt.
- **Fichiers de logs (`flutter_*.log`)** laissés à la racine du dossier (ignorés par Git mais toujours présents sur disque) — nettoyage possible sans impact.
- **`web/manifest.json`** garde le nom générique `frontend_flutter` et les couleurs de thème Flutter par défaut (`#0175C2`), non alignées avec le titre « ServiceConnect » utilisé dans `web/index.html` ni avec la couleur primaire réelle de l'app (`AppTheme.primary`, `#1A73E8`).
- **`AppTheme.darkTheme`** est défini mais jamais utilisé (l'app est câblée uniquement sur `AppTheme.lightTheme` dans `app.dart` et `main_register.dart`).
- **`lib/main_register.dart`** est un point d'entrée de développement pour prévisualiser isolément l'écran d'inscription ; il n'est pas utilisé par le `Dockerfile` (qui build `lib/main.dart` implicitement via `flutter build web`) mais reste présent dans le dépôt.
- **`lib/modules/dashboard/`** (route `/dashboard`) semble être un écran placeholder résiduel du scaffolding initial, distinct et non lié aux vrais dashboards client/prestataire déployés en production applicative.
