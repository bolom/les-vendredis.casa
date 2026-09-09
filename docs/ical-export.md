# Export iCal vers Airbnb et Booking.com

L'application expose les séjours directs et les blocages manuels dans un flux
iCalendar privé. Elle n'y inclut jamais les événements importés depuis Airbnb
ou Booking.com, afin d'éviter une boucle de synchronisation.

## Configuration

Générer un token opaque, long et aléatoire, puis l'enregistrer sous
`calendars.export_token` dans les credentials Rails de production. La variable
`ICAL_EXPORT_TOKEN` peut servir d'alternative hors production. Ne jamais placer
sa valeur dans Git, un ticket, un log ou une capture d'écran.

L'URL à fournir aux plateformes est :

```text
https://lesvendredis.casa/calendar/<TOKEN>.ics
```

Une requête sans le bon token retourne `404`. Le flux ne contient ni nom, ni
email, ni téléphone, ni référence de réservation : chaque période porte
seulement le libellé `Unavailable`.

Avant de connecter une plateforme, vérifier la réponse sans afficher le token
dans un terminal partagé : le statut doit être `200`, le type
`text/calendar`, et le document doit commencer par `BEGIN:VCALENDAR`.

## Airbnb

Depuis un ordinateur :

1. Ouvrir **Calendrier** et choisir l'annonce.
2. Ouvrir **Disponibilité** puis **Connecter les calendriers**.
3. Choisir **Connecter à un autre site web**.
4. Coller l'URL `.ics`, nommer le calendrier « Les Vendredis — direct », puis
   ajouter le calendrier.
5. Utiliser **Actualiser le calendrier** après une réservation urgente.

Airbnb annonce une actualisation automatique environ toutes les trois heures et
permet une actualisation manuelle, avec une limite de fréquence. Voir la
[procédure officielle Airbnb](https://www.airbnb.com/help/article/99).

## Booking.com

Dans l'Extranet, ouvrir **Tarifs et disponibilités** (ou **Calendrier et tarifs**
selon l'interface), puis **Synchroniser les calendriers** / **Importer un
calendrier**. Coller l'URL `.ics`, donner un nom au calendrier et terminer
l'import. Vérifier ensuite dans le calendrier que les dates directes et les
blocages manuels apparaissent comme indisponibles.

Les intitulés et la disponibilité de la synchronisation dépendent du type
d'hébergement et de la version de l'Extranet. Si l'option n'apparaît pas,
utiliser l'aide Booking.com depuis l'Extranet ou contacter le support partenaire.

## Limites et exploitation

- Le flux publie les blocs `direct` et `manual` aux statuts `tentative` ou
  `confirmed`. Un bloc `cancelled` disparaît au prochain rafraîchissement OTA.
- La synchronisation iCal n'est pas instantanée. Jusqu'au rafraîchissement de
  chaque plateforme, une fenêtre de double réservation subsiste.
- Pour une réservation imminente, actualiser manuellement les calendriers OTA
  et contrôler visuellement les dates.
- La rotation du token invalide immédiatement l'ancienne URL. Remplacer alors
  l'URL importée sur Airbnb et Booking.com.
