# SwiftyNavdata

SwiftyNavdata is a simple package to work with Infinite Flight Airport Editing Team's navdata formats and airports. It features support for both **.json** and **.dat** files, ```NavObject``` protocol which supplies the waypoint's name and location to simplify code writing, detailed airport data and protections against file anomalies.

## Usage

Using SwiftyNavdata is as simple as calling one of it's intuitevily named static functions, like ```NavdataParser.decodeFixDat(yourUrl)``` or ```AirportParser.parseAirportWithNodes(yourUrl)```.

## On DME support

DME doesn't work as of now, as I need to figure out code to distinguish between 2 different variants of them. As an example, it could be *12 47.43433300 -122.30630000    369 11030  18       0.000 ISNQ KSEA 16L DME-ILS* or it could be *12 47.43538889 -122.30961111    354 11680 130       0.0   SEA  SEATTLE VORTAC DME* - as you can see, they require different parsing while being under the same row code. I will try to find a solution to this problem, but for now it is not a significant problem, since IF does not have them in-game.

## Reporting Bugs

I've tested it on V37 build and it wen't well, but if you encounter any issues, you can always PM me on Discord or [IFC](https://community.infiniteflight.com/u/Alexander_Nikitin).
