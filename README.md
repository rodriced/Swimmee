# Swimmee

<p align="left">
    <a href="https://swift.org/">
        <img src="https://img.shields.io/badge/Swift-5.7+-F05138?color=blue&labelColor=303840" alt="Swift: 5.7+">
    </a>
    &nbsp; &nbsp;
    <a href="https://www.apple.com/ios/">
        <img src="https://img.shields.io/badge/iOS-15.5+-007AFF?labelColor=303840" alt="iOS: 15.5+">
    </a> 
</p>

[![Swimmee CI workflow](https://github.com/rodriced/Swimmee/actions/workflows/SwimmeeCI.yml/badge.svg)](https://github.com/rodriced/Swimmee/actions/workflows/SwimmeeCI.yml)

Swimmee is an iOS app that allows swimmers to sign up with coaches to track their workouts.

<br/>


## Context
I developped this iOS application (prototype) for the final project of an Openclassrooms iOS App Developer Training.

It's made with **SwiftUI** and **Combine** for the user interface and with some **Firebase modules** for the server side.

## Features and usage
First you must create an account as swimmer or coach with firstname, lastname, email and password.

After signed in with email and password.

- As a coach:
    - You can publish workouts and send messages to your team.
    - Some can be left as draft to work on it or send it later.
    - You can also unpublish or destroy it if needed.
    - For workouts, you can filter the list by
        - contained swimming exercise types,
        - or status (draft or published).
    - You can see your team that consists of swimmers who are subscribed to you.

- As a swimmer:
    - You can choose a coach among several and subscribe to one.
    - If you have subscribed to a coach you will receive messages from him and access to his published workouts. There is an indication to see if some workouts or messages are new.
    - For workouts, you can filter the list according to contained swimming exercise types.

All users can modify their profile and add a photo.

Swimmer can delete their account but for now this fuctionnality is not implemented for the coaches.

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

Then build the project in **Xcode 14+**
