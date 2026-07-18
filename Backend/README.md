# Projet Elame — Backend

Plateforme de mise en relation entre **clients** et **prestataires de services physiques** (plomberie, électricité, climatisation, réseau/wifi, maintenance, etc.).

---

## 1. Où en est le projet aujourd'hui

Important à comprendre avant tout : **il n'y a pas encore de logique métier**. Ce dépôt contient uniquement le **squelette** de l'architecture — la structure des dossiers, la configuration, Docker — prêt à recevoir le code métier module par module.

Aucune fonctionnalité (inscription, authentification, réservation, recherche...) n'est encore implémentée. Ce qui existe et fonctionne déjà :
- Un projet Spring Boot qui compile, démarre et se connecte à MySQL.
- Une organisation des packages qui **anticipe** une future architecture microservices.
- Des fichiers de configuration pour 3 environnements (dev, test, prod).
- Un `Dockerfile` et un `docker-compose.yml` fonctionnels.

## 2. Choix d'architecture : monolithe modulaire d'abord, microservices ensuite

Deux approches étaient possibles :
1. Créer tout de suite 9 microservices séparés (api-gateway, auth-service, user-service, etc.)
2. **Construire un seul projet Spring Boot, organisé en modules internes qui correspondent chacun à un futur microservice.**

C'est la **2ᵉ option** qui a été choisie, car :
- Elle permet d'écrire et tester la logique métier beaucoup plus vite (une seule base de code, une seule base de données, pas de réseau entre services).
- Les frontières entre modules sont déjà posées : quand le moment sera venu de séparer un module en vrai microservice, le travail sera surtout de le déplacer dans un projet séparé, pas de le re-concevoir.

Autrement dit : **le dossier `modules/auth` d'aujourd'hui deviendra le projet `auth-service` de demain**, sans changer sa logique interne.

| Module actuel | Deviendra | Responsabilité |
|---|---|---|
| `modules/auth` | `auth-service` | Inscription, connexion, JWT, rôles, permissions, mot de passe |
| `modules/user` | `user-service` | Profils client/prestataire, métiers, compétences, localisation, photos, documents |
| `modules/availability` | `availability-service` | Calendrier, disponibilités, horaires, congés |
| `modules/booking` | `booking-service` | Réservation, statut, acceptation/refus, historique |
| `modules/search` | `search-service` | Recherche et filtres (métier, date, heure, ville, disponibilité) |
| `modules/notification` | `notification-service` | Email, SMS, notifications push |
| `common` | `common-library` | Code partagé entre modules (pas un service à part entière) |

Les futurs `api-gateway`, `config-server` et `discovery-service` (Eureka) n'ont pas d'équivalent dans le monolithe : ce sont des briques d'infrastructure qui n'apparaîtront qu'au moment de la vraie séparation en microservices.

---

## 3. Fichiers à la racine du projet

| Fichier / Dossier | Rôle |
|---|---|
| `pom.xml` | Déclaration Maven du projet : version Spring Boot (**4.1.0**), dépendances (`spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `spring-boot-starter-validation`, `mysql-connector-j`, `lombok`, `springdoc-openapi-starter-webmvc-ui`, `h2` en scope test), configuration du plugin Lombok pour l'annotation processing. |
| `Dockerfile` | Build Docker en 2 étapes (multi-stage) : compilation Maven dans une image `eclipse-temurin:21-jdk` (étape `build`), puis copie du `.jar` final dans une image légère `eclipse-temurin:21-jre` (étape `runtime`). Permet de faire `docker build .` sans avoir besoin de lancer `mvn package` à la main avant. |
| `docker-compose.yml` | Démarre 2 conteneurs : `app` (l'application, profil `prod`) et `db` (MySQL 8.4 avec volume persistant). Contient une note expliquant que chaque futur microservice deviendra un bloc `service` séparé ici, avec sa propre base, lors de la vraie séparation. |
| `mvnw` / `mvnw.cmd` | Maven Wrapper — permet de compiler/lancer le projet sans avoir Maven installé globalement sur la machine (`./mvnw.cmd compile`, `./mvnw.cmd spring-boot:run`, etc.). `mvnw` est la version Linux/Mac, `mvnw.cmd` la version Windows. |
| `.mvn/wrapper/maven-wrapper.properties` | Précise la version exacte de Maven que le wrapper doit télécharger et utiliser. |
| `README.md` | Ce fichier — documentation du projet. |
| `Documentation-Projet-Elame-Backend.pdf` | Version PDF détaillée de cette documentation (générée à part, pas suivie par git). |
| `HELP.md` | Fichier d'aide généré automatiquement par Spring Initializr à la création du projet (liens vers la documentation officielle Spring Boot/Maven). Peut être supprimé sans impact. |
| `.gitignore` | Liste des fichiers/dossiers que Git ne doit pas suivre (`target/`, fichiers de build, fichiers IDE...). |
| `.gitattributes` | Règles Git sur la normalisation des fins de ligne et le traitement de certains types de fichiers. |
| `.vscode/settings.json` | Paramètres du projet spécifiques à l'éditeur VS Code (n'affecte pas le comportement de l'application). |
| `.github/modernize/java-upgrade/` | Scripts d'outillage générés automatiquement par un assistant de modernisation Java (hooks, scripts PowerShell/Bash). Sans lien avec la logique métier du projet. |

---

## 4. Code source Java — `src/main/java/com/renkotechnologie/backend/`

| Fichier | Rôle |
|---|---|
| `BackendApplication.java` | Point d'entrée de l'application. Contient la méthode `main()` et l'annotation `@SpringBootApplication`, qui déclenche le démarrage de tout le contexte Spring (scan des composants, auto-configuration, démarrage du serveur web intégré). |

Sous ce package, deux grands dossiers organisent tout le reste du code :
- **`modules/`** — le code métier, séparé par domaine (détaillé section 5).
- **`common/`** — le code partagé entre plusieurs modules (détaillé section 6).

---

## 5. Les 6 modules métier et leurs 19 sous-dossiers

Chaque module dans `modules/` (`auth`, `user`, `availability`, `booking`, `search`, `notification`) suit **exactement la même structure interne**, avec 19 sous-dossiers identiques. Aujourd'hui, chaque sous-dossier contient uniquement un fichier `package-info.java` — un fichier Java valide dont le seul rôle est de documenter la fonction du dossier (via un commentaire Javadoc), en attendant que le vrai code y soit ajouté module par module. Ce choix garantit que `mvn compile` fonctionne dès maintenant, même si les dossiers sont vides de logique.

| Sous-dossier | Rôle une fois rempli |
|---|---|
| `config/` | Classes de configuration Spring propres au module (beans spécifiques, propriétés custom). |
| `controller/` | Contrôleurs REST : définissent les endpoints HTTP exposés par le module (ex : `POST /auth/login`, `GET /booking/{id}`). |
| `dto/` | Data Transfer Objects — objets utilisés pour échanger des données entre l'API et le code interne, sans exposer directement les entités JPA. |
| `entity/` | Entités JPA — classes annotées `@Entity` qui représentent les tables en base de données. |
| `mapper/` | Conversion entre entités et DTO (et inversement), pour éviter d'exposer les entités JPA brutes dans les réponses API. |
| `repository/` | Interfaces Spring Data JPA (`extends JpaRepository<...>`) pour accéder à la base de données (requêtes, CRUD). |
| `service/` | Interfaces définissant le contrat de la logique métier du module (sans implémentation). |
| `service/impl/` | Implémentations concrètes des interfaces de `service/` — c'est ici que vit la vraie logique métier (calculs, règles, orchestration). |
| `security/` | Règles de sécurité propres au module (ex : vérifier qu'un prestataire ne peut modifier que ses propres disponibilités). |
| `exception/` | Exceptions métier spécifiques au module (ex : `BookingAlreadyAcceptedException`, `InvalidCredentialsException`). |
| `client/` | Appels sortants vers d'autres modules ou services externes (REST aujourd'hui, OpenFeign une fois en microservices). |
| `event/` | Définition des événements métier du module (ex : `BookingCreatedEvent`, `UserRegisteredEvent`) — prépare la communication asynchrone future. |
| `producer/` | Émission de messages/événements vers une file d'attente. **Réservé pour plus tard** — aucune dépendance RabbitMQ/Kafka n'est encore ajoutée au projet. |
| `consumer/` | Réception et traitement de messages venant d'une file d'attente. **Réservé pour plus tard**, idem. |
| `listener/` | Écouteurs d'événements internes à l'application (ex : réagir via `@EventListener` à un événement publié par un autre module). |
| `scheduler/` | Tâches planifiées/récurrentes (ex : rappel de rendez-vous la veille, nettoyage de réservations expirées). |
| `util/` | Fonctions utilitaires propres au module. |
| `constant/` | Constantes propres au module (ex : codes de statut de réservation : `PENDING`, `ACCEPTED`, `REFUSED`). |
| `validator/` | Règles de validation métier personnalisées, au-delà des annotations Bean Validation standard (`@NotNull`, etc.). |

### Détail métier par module

- **`modules/auth`** : création de compte, connexion, génération/validation des tokens JWT, refresh token, gestion des rôles (client / prestataire) et permissions, changement de mot de passe.
- **`modules/user`** : gestion des profils client et prestataire — informations personnelles, métiers exercés, compétences, localisation, photos de profil, documents justificatifs.
- **`modules/availability`** : calendrier du prestataire — définition des horaires de disponibilité, jours ouvrables, congés, plages horaires modifiables.
- **`modules/booking`** : cycle de vie d'une réservation — création de la demande, acceptation/refus par le prestataire, annulation, suivi de statut, historique des interventions.
- **`modules/search`** : recherche de prestataires côté client, avec filtres combinables (métier, ville, date, heure, disponibilité).
- **`modules/notification`** : envoi de notifications au client et au prestataire (email, SMS, push) suite aux événements du parcours (nouvelle demande, acceptation, rappel...).

---

## 6. Le dossier `common/`

Contrairement aux modules ci-dessus, `common/` ne deviendra **pas** un microservice — c'est une bibliothèque de code partagé (future `common-library`), utilisée par plusieurs modules à la fois. Il ne contient donc pas de `controller`, `repository`, `service`, `client`, `producer`, `consumer`, `listener` ou `scheduler` (ça n'aurait pas de sens pour du code partagé), seulement les couches transversales :

| Sous-dossier | Rôle une fois rempli |
|---|---|
| `common/config/` | Configuration partagée (ex : configuration CORS, configuration Jackson/JSON, configuration OpenAPI globale). |
| `common/dto/` | DTO génériques réutilisés par plusieurs modules (ex : enveloppe de réponse standard `ApiResponse`, pagination `PageResponse`). |
| `common/entity/` | Classe de base partagée pour les entités (ex : champs d'audit communs `createdAt`/`updatedAt` via une `BaseEntity` héritée). |
| `common/exception/` | Gestionnaire d'exceptions global (`@ControllerAdvice`) et exceptions génériques réutilisables par tous les modules. |
| `common/security/` | Utilitaires de sécurité partagés (ex : récupération de l'utilisateur courant depuis le contexte de sécurité Spring). |
| `common/event/` | Classe de base pour tous les événements métier de l'application. |
| `common/util/` | Fonctions utilitaires génériques, utilisées par plusieurs modules. |
| `common/constant/` | Constantes globales de l'application. |
| `common/validator/` | Validateurs génériques réutilisables (ex : validation de format de numéro de téléphone). |

---

## 7. Fichiers de configuration — `src/main/resources/`

Le projet utilise les **profils Spring** pour séparer la configuration selon l'environnement d'exécution.

| Fichier | Utilisé quand | Contenu clé |
|---|---|---|
| `application.yml` | Toujours (base commune, chargée en premier) | Nom de l'application (`backend`), profil actif par défaut (`dev`), port du serveur (`8080`), `jpa.open-in-view: false`, niveau de log racine. |
| `application-dev.yml` | Développement local (`./mvnw.cmd spring-boot:run`) | Connexion MySQL locale (`jdbc:mysql://localhost:3307/backend_db`, utilisateur `assako`), `ddl-auto: update` (les tables se créent/mettent à jour automatiquement selon les entités JPA), SQL affiché et formaté dans les logs, Swagger UI activé, logs en `DEBUG` pour le package du projet. |
| `application-test.yml` | Exécution des tests (`./mvnw.cmd test`) | Base **H2 en mémoire** en mode compatibilité MySQL (`MODE=MySQL`) — aucune base externe nécessaire pour lancer les tests. `ddl-auto: create-drop` (le schéma est recréé à chaque exécution puis détruit à la fin). |
| `application-prod.yml` | Déploiement (VPS, Docker) | Tous les paramètres sensibles viennent de variables d'environnement (`${DB_URL}`, `${DB_USERNAME}`, `${DB_PASSWORD}`, `${SERVER_PORT:8080}`), `ddl-auto: validate` (l'application vérifie que le schéma correspond aux entités mais ne le modifie jamais automatiquement — plus sûr en production), logs réduits (`WARN`/`INFO`). |

Le profil actif par défaut est `dev` (défini dans `application.yml`). On peut le changer via la variable d'environnement `SPRING_PROFILES_ACTIVE`.

> **Note :** la demande d'architecture initiale prévoyait PostgreSQL (une base par microservice). Le projet utilise **MySQL** à la place, par choix pratique (déjà installé sur la machine de dev — instance `MySQLbackend` sur le port `3307`, utilisateur `assako`). Si le projet est un jour découpé en microservices, ce choix vaudra pour chacun (`auth_db`, `user_db`, etc.), sauf décision contraire à ce moment-là.

---

## 8. Tests — `src/test/java/com/renkotechnologie/backend/`

| Fichier | Rôle |
|---|---|
| `BackendApplicationTests.java` | Test de démarrage minimal (`contextLoads`) : vérifie que le contexte Spring se charge sans erreur. Utilise le profil `test` (donc H2 en mémoire) via `@ActiveProfiles("test")`, et ne nécessite donc aucune base de données externe pour s'exécuter. |

Les dossiers `controller/`, `service/`, `repository/`, `integration/` prévus pour les tests futurs n'existent pas encore — ils seront créés au fur et à mesure que chaque module reçoit sa logique métier et ses tests associés (JUnit 5 + Mockito + Spring Boot Test, déjà inclus via `spring-boot-starter-test`).

---

## 9. Docker

- **`Dockerfile`** :
  1. Étape `build` (`eclipse-temurin:21-jdk`) : copie `pom.xml` et le wrapper Maven, télécharge les dépendances (`dependency:go-offline`), copie le code source, compile le `.jar` (`mvnw package`).
  2. Étape `runtime` (`eclipse-temurin:21-jre`, plus légère car sans outils de compilation) : copie uniquement le `.jar` final, expose le port `8080`, démarre avec `java -jar app.jar`.
- **`docker-compose.yml`** : démarre 2 conteneurs :
  - `app` → l'application Spring Boot (profil `prod`).
  - `db` → MySQL 8.4, avec un volume nommé (`backend_mysqldata`) pour que les données persistent entre redémarrages.

  Une note dans le fichier rappelle que chaque futur microservice deviendra un bloc `service` séparé dans ce fichier, avec sa propre base.

---

## 10. Comment lancer le projet

**En local (sans Docker), avec MySQL déjà installé :**
```
./mvnw.cmd spring-boot:run
```
(profil `dev` actif par défaut → connexion à MySQL local `backend_db` sur le port `3307`)

**Lancer les tests :**
```
./mvnw.cmd test
```
(profil `test` → H2 en mémoire, aucune base externe nécessaire)

**Avec Docker Compose (app + MySQL) :**
```
docker compose up --build
```

---

## 11. Ce qui n'existe pas encore (prochaines étapes)

- Aucune entité, aucun endpoint, aucune logique métier dans les modules.
- Pas de sécurité (`spring-boot-starter-security` volontairement absent — sera ajouté avec le module `auth`, en même temps que la logique JWT, pour éviter de sécuriser des endpoints qui n'existent pas encore).
- Pas de Config Server, Eureka (discovery), API Gateway — ces briques n'ont de sens qu'au moment de la vraie séparation en microservices.
- Pas de pipeline CI/CD (GitHub Actions).
- Pas de dépendance de messagerie (RabbitMQ/Kafka) — les dossiers `event/producer/consumer/listener` sont des emplacements réservés en attendant.

**La suite logique** : implémenter le module `auth` en premier (tous les autres modules en dépendent pour identifier qui fait la requête), puis `user`, puis les autres modules métier un par un (`availability`, `booking`, `search`, `notification`).
