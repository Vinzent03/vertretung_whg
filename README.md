![Twitter](https://img.shields.io/twitter/follow/Vinadon_?label=Text%20me&style=social)
![Plattform](https://img.shields.io/badge/Plattform-Android-blue)
![Flutter](https://img.shields.io/badge/Flutter%20-based-blue)
![](https://img.shields.io/github/workflow/status/Vinzent03/vertretung_whg/Build_APK_based_on_Commit)
# Vertretung
Eine Vertretungsapp für das Werner-Heisenberg-Gymnasium.

# Eigene Verwendung
**Wichtig: Die App arbeitet noch mit eingetragenen Daten. Sie schaut also noch nicht nach Vertretung im Internet.**

Die Flutter App ist auf das Werner-Heisenberg-Gymnasium zugeschnitten. Für die Nutzung and anderen Schulen:
1. Die App signen [siehe Flutter Dokumentation](https://flutter.dev/docs/deployment/android#signing-the-app)
2. Die Klasse [Filter](lib/logic/filter.dart) und  die Methode [getData()](lib/vertretung/FunctionsForVertretung.dart) auf die Daten der Schule anpassen. 
3. Eigene google-services.json in [android/app](android/app) einfügen. ([siehe Firebase](https://firebase.google.com/))
4. In [main.dart](lib/main.dart) eigene Keys für wiredash.io einfügen 
5. Kontaktiere mich dann bitte, um auch die Firebase Functions zu nutzen.

# Screenshots
<img 
    src = Images/IntroScreen.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/VertretungPageLightMode.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/FriendPageLightMode.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/SettingsPageLightMode.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/VertretungPageDarkMode.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/FriendPageDarkMode.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/NewsPageDarkMode.png
    alt= "IntroScreen"
    width = 150>
<img 
    src = Images/SettingsPageDarkMode.png
    alt= "IntroScreen"
    width = 150>

# Features
## Personalisierte Vertretung
Du kannst deine Fächer auswählen, anschließend siehst du einen extra Bereich für deine eigene Vertretung, dein eigener Bereich also.

## Benachrichtigungen
Wenn du Benachrichtigungen einschaltest, bekommst du Benachrichtigungen wenn sich etwas für dich verändert.

## Freunde
Wenn du Freunde hinzufügst siehst du einen Bereich mit der Vertretung deiner Freunde. So weißt so immer wann sie frei haben.

## Authentication
Wenn du dich anmeldest(freiwillig) kannst du dich an einem anderen Gerät anmelden und musst nicht alles neu einstellen.