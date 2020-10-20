![build status](https://img.shields.io/github/workflow/status/Vinzent03/vertretung_whg/Build%20APK%20based%20on%20commit)
![Platform](https://img.shields.io/badge/Plattform-Android-blue)
![Flutter](https://img.shields.io/badge/Flutter%20-based-blue)

# Vertretung

A German Flutter app to show the substitution of teachers in schools and share news. 

# Getting started
**Important: The UI of this app is in german, so if you don't speak german you would have to translate all UI texts.**

This app is specially designed for Werner Heisenberg Gymnasium Germany, but can be used with some changes at other schools too:

1. Change the class [Filter](lib/logic/filter.dart) and the method [getData()](lib/substitute/substituteLogic.dart) to your needs. 
2. Put your `google-services.json` from [Firebase](https://firebase.google.com/) into [android/app](android/app)
3. Set your Wiredash keys in [main.dart](lib/main.dart) from wiredash.io
4. Sign the app ([see documentation](https://flutter.dev/docs/deployment/android#signing-the-app)).
5. Deploy needed cloud functions from  [cloud-functions-for-vertretung_whg](https://github.com/Vinzent03/cloud-functions-for-vertretung_whg) to your firebase project.

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

## Personal Substitute

You can select you subjects and you will see in an extra tab just substitute for your selected subjects. So you don't have to see any information that is not important to you.

## Notification

If you turn on notifications, you will be notified for new substitute.

## Friends

If you add friends, you will see the substitute of you friends, so you don't have to ask them if they are free too.

## News

In the news tab you can see news and you will be notified when a news in added. They can only be added by admins ([see cloud functions](https://github.com/Vinzent03/cloud-functions-for-vertretung_whg#admins)).

## Authentication

If your create an account, which is not necessary, you can transfer you settings from one device to another. You can be signed in on two devices simultaneously, but the settings wont be synced. Your settings will only be synced from cloud to client on signIn. In addition an email account is required to be admin.