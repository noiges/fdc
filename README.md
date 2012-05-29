# igc-kml
A Ruby tool for converting IGC files to KML.

## Requirements

* Ruby 1.9.3 (get it from [ruby-lang.org](http://www.ruby-lang.org/en/downloads/))

## Install
### From RubyGems.org
This is the primary, convenient way to install the latest version of this tool. From your console (e.g. Terminal.app on Mac OS X, or CMD.exe on Windows), enter the following:
	
	% gem install igc-kml

### From source
If your are a developer and want to install from source, follow these steps:

1. Clone this repository: `git clone git@github.com:nokinen/igc-kml.git`
2. `cd igc-kml` 
3. Build: `gem build igc-kml.gemspec`
4. Install locally: `gem install igc-kml-X-X-X.gem`

## Usage
	
Convert one or more .igc files to .kml:

	% igc-kml <filepattern>

See help:

	% igc-kml -h