# diginotescreen

Diginote screen is the companion app to [Diginote](https://github.com/kelvin589/diginote) to display messages. A documentation page for the public libraries can be found [here](https://kelvin589.github.io/diginotescreen/).

## Table of Contents
* [Overview](#overview)
* [Features](#features)
* [Possible Improvements](#possible-improvements)
* [Setup](#setup)

## Overview
A paired Diginote Screen is used to display messages from [Diginote](https://github.com/kelvin589/diginote).
[![Diginote Demo](https://img.youtube.com/vi/rFyTfdWfLe4/0.jpg)](https://www.youtube.com/watch?v=rFyTfdWfLe4 "Diginote Demo")

## Features
* Easy screen pairing.
* Messages can be displayed with various customisation options
* Messages can be scheduled.
* A generated QR code leads to a pre-populated Google Forms with your email.

## Possible Improvements
* Adding interactivity to the screen for viewers (e.g., to alert staff). 
* Custmoisable screen background.
* Two-way communication (e.g., text chat).
* A way to subscribe to a screen (e.g., by QR code) to receive notifications of messages on a viewer's mobile device.
* An option to display a title on the screen (e.g., room name)
* An option to position the QR code and modify the link.

## Setup
1. Setup your development environment by following the official Flutter guide
    * https://docs.flutter.dev/get-started/install
    * Follow the first two steps (1. Install and 2. Set up an editor)
2. Setup an emulator (iOS, Android, Chrome, etc.)
3. Follow the Firebase guide to install and setup Firebase CLI
    * https://firebase.google.com/docs/cli
4. Run ```dart pub global activate flutterfire_cli``` to install FlutterFire CLI
5. Register for a firebase account (note: the project must be on the Blaze plan for notifications and the QR code to work properly)
6. Open Firebase console
7. Set up Authentication
    * Enable the email/password provider
9. Set up Firestore Database
    * Set up the security rules to allow for read and write
11. Set up Realtime Database
    * Set up the security rules to allow for read and write
13. Set up Firebase Cloud Functions (see the [diginote_cloud_functions](https://github.com/kelvin589/diginote_cloud_functions) repository)
15. Clone the project to get a local copy
``` bash
git clone https://github.com/kelvin589/diginotescreen
```
16. Change your directory to the project folder
``` bash
cd diginotescreen
```
17. Install dependencies
``` bash
flutter pub get
```
18. Initialise FlutterFire from the project's root
``` bash
flutterfire configure
```
20. Open main.dart and run the project on an emulator
