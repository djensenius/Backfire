# Backfire

> [!CAUTION]
> As of 20 April 2026, this project is no longer maintained and has been archived. My board broke and I don't have a newer one to test with. Feel free to fork and continue development if you have a board and want to keep this project alive.

 Simple iOS, watchOS, macOS app to read data from Backfire Skateboards.

 This code is all done by reverse engineering the bluetooth connection on the [Backfire Zealot S](https://www.backfireboards.com/products/backfire-zealot-s-belt-drive-electric-skateboard) electric skateboard.
 
 See [this page](https://djensenius.github.io/Backfire/) for screenshots.

 ## Data (work in progress)

 Bytes received from BTLE connection

 ```
       - 0 : 172
       - 1 : 6
       - 2 : 25
       - 3 : 1 
       - 4 : 1 // Mode (1 economy, 2 sport, 3 turbo)
       - 5 : 85 // Battery percent
       - 6 : 80 // Speed (km/h * 4 ???)
       - 7 : 188
       - 8 : 80
       - 9 : 204
       - 10 : 188
       - 11 : 224
       - 12 : 0
       - 13 : 36
       - 14 : 0
       - 15 : 0
       - 16 : 0
       - 17 : 3 // Distance in hectometer ???
       - 18 : 0
       - 19 : 0
 ```
