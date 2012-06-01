# igc-kml [![Build Status](https://secure.travis-ci.org/nokinen/igc-kml.png)](http://travis-ci.org/nokinen/igc-kml) [![Dependency Status](https://gemnasium.com/nokinen/igc-kml.png)](https://gemnasium.com/nokinen/igc-kml)
A command-line tool written in Ruby for converting files in the avionics [flight recorder data format](http://carrier.csi.cam.ac.uk/forsterlewis/soaring/igc_file_format/igc_format_2008.html) (.igc) to the [keyhole markup language](https://developers.google.com/kml/documentation/) (.kml) for their display in Applications such as [Google Earth](earth.google.com).

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