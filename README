Denver Rail RTD light rail iOS application

About
=====
Denver Rail is an iOS application tailored to run on iPhone and iPod Touch devices. It is intended to help users find stations, routes, and arrival/departure times. 

Sources 
=======
The application gets its data from http://www.rtd-denver.com/GoogleFeeder/. It is then stored into a sqlite database. Provided is a document on how to update the time tables if necessary. The database library is found here https://github.com/ccgus/fmdb. 

Running 
=======
The application is first started into if the user allows location setting."Auto" mode which automatically locates the nearest station to the user. It is intended to default to either the northbound/eastbound train. However, there are a small number of trains who only have one direction trains. So if the station does not have a train in that direction then it defaults to the other direction and disables the button for the direction that does not exist. 

The auto mode screen shows the direction of the station, distance away, and the rail line letter and time in the cells. 

One can tap on the auto mode button to turn it off, setting it into manual mode. Manual mode allows the user to select the light board name of the station and choose any station they want. Selecting from the list will bring up the times for that selected station. 

Below the station name in manual mode there is information that shows the current time. Selecting this brings up a timer where the user can select the specific time/date and then see the rail schedule for that time. 

In the upper left corner of the application there is a map button. Selecting the map button will bring up a map of the Denver Rail Stations and routes. The user can then pinch to zoom in or out, along with double tapping to zoom in. There is a legend for the rail lines and also Letter zones which effect the cost of the travel. More zones, would result in a higher price. Selecting the map button again will bring up the main screen again. 