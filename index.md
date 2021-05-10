# Backfire Board Tracker

I recently got a [Backfire Zealot S](https://www.backfireboards.com/products/backfire-zealot-s-belt-drive-electric-skateboard) electric skateboard. I was not satisfied with any of the electric skateboard tracking apps out there. I built my own. It supports iOS, watchOS, and soon macOS.

## Features
* Track your current ride on your phone, tablet, or watch.
* See your current speed, distance, and battery life on your phone, tablet, or watch.
* View your previous rides on your phone or tablet.
* Grabs and saves the weather of your ride.
* Watch users track rides as workouts (you don’t burn a lot of calories, but it’s balance work, right? 🤷)

## Screenshots

### Apple Watch
![Apple Watch](/Backfire/assets/images/IMG_3889.PNG)

### iPhone Rides
![iPhone Rides](/Backfire/assets/images/IMG_3890.PNG)

### iPhone Ride Summary
![iPhone Ride Summary (some data missing as this was done in the simulator)](/Backfire/assets/images/2021-04-10.png)

Some data missing is missing from this screenshot as it was done in the simulator. Data should work on your device.

### iPhone Current Ride
![iPhone Current Ride](/Backfire/assets/images/IMG_3885.PNG)

### macOS Ride Summary
![macOS Screenshot](/Backfire/assets/images/macScreenshot.png)

I've blurred the map out for privacy reasons. It is not really blurry, I promise!


<a id="privacy"></a>


## Privacy Policy

While this app uses your location and bluetooth, no data collected is available to the developers of the app. All data is stored in a secure cloud container on Apple Servers that only you have access to.


## FAQ

**Is this an official Backfire Board application?**

It is not. This is a hobby app and is in no way connected to or associated with Backfire Boards. I needed to reverse engineer the bluetooth data as the spec is not provided by Backfire or Hobbywing.

**Does it work with my board?**

Maybe? I have only tested it on the Backfire Zealot S. If your board is a Backfire board and has BLE then it might work.

**Will this work on Android?**

No.

**Will this ever support Android?**

Almost certainly not, it's built using Apple technologies like CloudKit. If you are feeling ambitious, I'm more than happy to have contributors!

**Is there a macOS version?**

I don't recommend riding your electric skateboard while holding a Mac, but yes. Contact me through iOS test flight for access.

**How can I use it?**

Contact me for a TestFlight beta.


### Support or Contact

Create an [issue](https://github.com/djensenius/Backfire/issues).
