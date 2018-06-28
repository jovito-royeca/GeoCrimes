# GeoCrimes

An iOS app that shows crime occurences in the UK for a given month in a map.

Data comes from https://data.police.uk/docs/method/crimes-at-location/.

## Features

- Initial location is London, UK
- Uses Cocoapods for third party dependency management
- Uses MVC design pattern
- Uses Google Maps library

## Building
Make sure to edit the file `Configuration.swift` and change the value of `kGoogleMapsAPIKey`to a valid Google Maps API key.

Clone the GitHub repository and open the project workspace `GeoCrimes.xcworkspace`. You may need to install the Cocoapod dependencies first.

```
$ git clone https://github.com/jovito-royeca/GeoCrimes.git
$ cd GeoCrimes
$ pod install
$ open GeoCrimes.xcworkspace
```

## Author

Jovito Royeca
jovit.royeca@gmail.com
