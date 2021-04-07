# Backfire
Simple iOS, watchOS, macOS app to read data from Backfire Skateboards.

This code is all done by reverse engineering the bluetooth connection on the [Backfire Zealot S](https://www.backfireboards.com/products/backfire-zealot-s-belt-drive-electric-skateboard) electric skateboard.

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
