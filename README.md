#  Swimmee
[![Swimmee CI workflow](https://github.com/rodriced/Swimmee/actions/workflows/SwimmeeCI.yml/badge.svg)](https://github.com/rodriced/Swimmee/actions/workflows/SwimmeeCI.yml)

Swimmee is an iOS application that connects swimmers with training coaches.

## Context
I developped this iOS application prototype for the final project of an Openclassrooms iOS App Developer Training.

It's based on SwiftUI and Combine for the user interface and on some Firebase modules for the server part.

## Features and usage
First you must create an account as swimmer or coach with firstname, lastname, email and password.

After signed in with email and password:

- As a coach you can publish workouts and send messages to your team. Some can be left as draft.
You can see your team that is made up of swimmers who are subscribed to you.

- As a swimmer you can choose a coach among several and subscribe to one.
Then you will receive messages from him and access to his published workouts.

All users can modify their profile and add a photo.

Swimmer can delete their account but for now this fuctionnality is not implemented for the coachs.

## Installation
To test Swimmee you have to:
- create a Firebase project;
- dwnload GoogleService-Info.plist file from Firebase project and put it in place of the existing empty one in the Swimmee folder of the application project;
- activate the following services :
    - Authentication
    - Storage
    - Firestore

You can also activate Analytics, Performances and Crashlytics because corresponding modules are installed in the project but it's optionnal.

For Firestore you must create the following indexes:
| Collection ID | Fields indexed | Query scope |
| ------------- | -------------- | ----------- |
| Messages      | userId Ascending date Descending | Collection |
| Profiles      | userType Ascending lastName Ascending | Collection |
| Workouts      | userId Ascending date Descending | Collection |
| Messages      | isSent Ascending userId Ascending date Descending | Collection |
| Profiles      | coachId Ascending lastName Ascending | Collection |
| Workouts      | isSent Ascending userId Ascending date Descending | Collection |   

Then compile the project in Xcode (I used Xcode 14.1)