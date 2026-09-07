# Audit Rails — corrections à réaliser

Audit du 7 septembre 2026, commit `d2bbfa8`. Relecture du code, du schéma PostgreSQL et des tests ; suite relancée : **71 tests, 352 assertions, zéro échec**. Ce résultat ne valide pas un achat : aucun parcours de paiement réussi n'est implémenté. Aucune transaction externe effectuée. Production et livraison réelle des emails non revérifiées dans cet audit.

## P0 — avant activation des paiements (issue #11)

- [ ] **PAY-01 — Ne pas proposer un challenge inutilisable.** `MachineBookingsController#book` renvoie 402 même sans destinataire ; `Quote#payment_configured?` vérifie seulement sa présence. Valider destinataire, réseau, actif, décimales et montant au démarrage/activation, dans les credentials Rails. Renvoyer une indisponibilité explicite quand la configuration ou le vérificateur manque. Validation : configuration absente/invalide ⇒ aucun challenge payable ; découverte cohérente avec l'état réel.
- [ ] **PAY-02 — Implémenter et vérifier le protocole de paiement choisi.** `/book` ignore toute preuve et renvoie toujours 402. Documenter la version du protocole, utiliser son format officiel et vérifier côté serveur destinataire, actif, réseau, montant et expiration. Validation : client compatible, preuve valide acceptée ; preuve absente, falsifiée, expirée ou portant sur un autre séjour refusée. Ne pas assimiler un simple statut 402 à une intégration x402 fonctionnelle.
- [ ] **PAY-03 — Persister devis, paiement et réservation.** Aucun modèle de paiement dans le schéma ; devis recalculé et expiration renouvelée à chaque requête. Ajouter un devis identifié et immuable, un paiement distinct, une clé d'idempotence et une protection contre le rejeu. Validation : prix modifié après devis, retries et même preuve sur deux séjours ; une seule confirmation et un seul bloc.
- [ ] **PAY-04 — Traiter concurrence et échec après paiement.** Définir réservation temporaire, expiration, règlement et compensation/remboursement si les dates deviennent occupées. Conserver la contrainte PostgreSQL anti-chevauchement déjà présente. Validation : deux acheteurs concurrents, import iCal concurrent, fournisseur indisponible et reprise après interruption ; aucun double séjour et suivi de chaque paiement encaissé.

## P1 — exactitude et protection des réservations

- [ ] **BOOK-01 — Refuser les séjours passés.** `Availability::Check#available?` et `StayRule#validate_stay` ne refusent pas les dates passées, contrairement au calendrier journalier. Appliquer la même règle aux demandes et devis, sans empêcher l'administration des séjours historiques. Validation : hier refusé, aujourd'hui traité selon la règle métier, fuseau Martinique testé.
- [ ] **BOOK-02 — Valider strictement les paramètres et capacités.** `Integer(value)` tronque les nombres JSON fractionnaires ; `Quote` transforme automatiquement les voyageurs supplémentaires en enfants. Exiger des entiers bornés, recueillir adultes/enfants explicitement et gérer les types JSON inattendus sans 500. Validation : fractions, tableaux, objets, très grands nombres et trois adultes refusés avec capacité deux adultes/un enfant.
- [ ] **BOOK-03 — Encadrer les transitions et conflits.** `decline!` peut refuser une demande acceptée sans libérer son bloc ; l'annulation du bloc ne synchronise pas la demande. Définir transitions atomiques et idempotentes, règles d'annulation et notifications uniques. Traiter aussi les violations de contrainte PostgreSQL lors d'acceptations concurrentes : le contrôleur ne récupère actuellement que `RecordInvalid`. Validation : accepter deux fois, refuser après acceptation, annuler et concurrence sans 500 ni état contradictoire.
- [ ] **BOOK-04 — Enregistrer un accord effectivement soumis.** La case du formulaire n'a pas de `name`, mais le contrôleur remplit toujours `consent_at`. Nommer le champ, le valider côté serveur et dater uniquement l'accord reçu. Validation : POST direct sans accord refusé ; accord valide conservé.
- [ ] **SEC-01 — Limiter les abus et masquer les données personnelles.** Seule la connexion possède un `rate_limit` ; le filtre des logs n'inclut pas nom, téléphone, message ou dates du séjour. Ajouter limitations adaptées aux demandes/devis et filtrage explicite. Validation : dépassement ⇒ 429 ; données et preuves sensibles absentes des logs ; réservation normale possible.
- [ ] **MAIL-01 — Fiabiliser et vérifier les notifications (#17).** La demande est sauvegardée avant deux mises en file successives. Vérifier récupération si la file échoue, retries sans doublons, worker production et livraison Resend. Validation : demande conservée et notification récupérable après panne ; accusé et notification propriétaire reçus dans un test contrôlé.

## P2 — terminer la migration et la recette

- [ ] **UX-01 — Traduire tout le parcours FR.** Les vues `booking_inquiries/new` et `show` restent anglaises malgré `locale=fr`. Traduire champs, erreurs, accord, confirmation et emails ; préserver la langue après validation/redirect. Validation navigateur FR/EN, mobile, clavier et soumission invalide puis valide.
- [ ] **PRICE-01 — Unifier le prix affiché et facturé (#11).** Le tarif machine vient d'un défaut de 74 et les décimales sont fixées à six. Définir une source de prix administrable, précision, frais/taxes et devise ; valider montant positif et conversions sans troncature. Validation : même total calendrier/devis/paiement, configuration malformée traitée proprement.
- [ ] **DOC-01 — Actualiser les documents actifs.** L'ADR décrit encore Jekyll en production, exclut les endpoints paiement et place les secrets applicatifs dans 1Password. Documenter Rails seul, credentials chiffrés avec seule master key dans le vault, et statut incomplet du paiement. `AGENTS.md` est également obsolète mais doit rester intact conformément à l'instruction utilisateur ; mettre les consignes actuelles dans le README.
- [ ] **QA-01 — Compléter les tests manquants.** Ajouter les régressions ci-dessus, figer l'horloge des tests aux dates fixes de novembre 2026, puis une recette navigateur demande → acceptation et paiement simulé → confirmation. Les tests actuels vérifient seulement le refus 402, pas l'achat. Validation : tests reproductibles après novembre 2026 et parcours critiques exécutés en localhost.
- [ ] **OPS-01 — Clore la bascule avec preuves (#10, epic #5).** Vérifier import du contenu/journal, inventaire des anciennes URL, canonical/hreflang/sitemaps, assets, jobs iCal, sauvegarde/restauration, domaine et santé production. Consigner les résultats et anomalies ; ne pas déclarer la migration totalement terminée sur la seule suite locale verte.

## Ordre recommandé

BOOK-01 à BOOK-04 et SEC-01 ; PAY-01 ; PAY-02 à PAY-04 avec PRICE-01 ; MAIL-01 et UX-01 ; DOC-01, QA-01 et OPS-01. Chaque tâche reste ouverte jusqu'à obtention de ses critères de validation.

## Avancement du 7 septembre 2026

- BOOK-01 et BOOK-04 corrigés et testés : refus du passé, accord explicite côté serveur.
- BOOK-02 : entiers stricts et bornés, adultes/enfants distincts, tests des fractions, tableaux et capacités ; autres formes de requêtes à approfondir.
- BOOK-03 : acceptation/refus idempotents, refus interdit après acceptation, annulation du bloc synchronisée, dates liées protégées, conflit PostgreSQL récupéré. Test de concurrence réelle et notifications d'annulation restent à compléter.
- PAY-01 : paiement fermé explicitement (503, aucun challenge), découverte alignée. Validation de configuration à ajouter avec le futur vérificateur.
- SEC-01 : limites de requêtes et filtres sensibles ajoutés ; tests spécifiques de dépassement/logs restent ouverts.
- UX-01 : formulaire et confirmation français disponibles ; traduction exhaustive des erreurs reste ouverte.
- DOC-01 : README actualisé et ADR annotée ; AGENTS.md préservé.
- QA-01 : horloge des tests figée ; **76 tests / 368 assertions passent**, RuboCop : **102 fichiers, aucune infraction**.
- Chrome installé, mode headless, viewport 390 × 844 : demande FR envoyée sur dates disponibles, confirmation `LV-TPFBFDBC`, aucune erreur JavaScript ; `/book` vérifié à 503. Capture locale : `/tmp/rails-booking-chrome.png`. Le premier essai sur dates occupées a bien été refusé.
- La demande fictive reste dans la base de développement, non confirmée et non bloquante. Les emails de développement vont dans des fichiers locaux.
- PAY-02/03/04, PRICE-01, MAIL-01 et OPS-01 restent ouverts. Aucun achat réel, déploiement ni envoi externe validé par cette recette.
