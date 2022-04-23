# Vehicle Finder Assignment 


This project fetches the vehicle list from this url "https://takehometest-production-takehometest.s3.eu-central-1.amazonaws.com/public/take_home_test_data.json" and adds them as annotains to the map and if there is a problem in this flow, shows an alert dialogue with error message. if user clicks on each annotation, can see the information of the vehicle in a bottom sheet and also if the user clicks on "Show Closest Vehicle" button, app gets an access to user's current location and after finding nearest vehicle, shows a bottom sheet. user also can show the location of that vehicle on Apple's Maps application by clicking on "Show in Maps" button of presented dialogue.


* In this project, the MVVM design pattern is used to have a good separation of concerns and make the it testable.
* All layers separated by Protocols.
* The Combine framework is used for data binding.
* The logging feature and centering map location are disabled in release mode and project is now production-ready. the archive phase uses release configuration.
* Most logic part of application covered by unit tests. the code coverage is about 72 percents.
