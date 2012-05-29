# igc-kml
A Ruby tool for converting IGC files to KML.

## Requirements

* At least Ruby 1.8.7
* RubyGems

## Setup

1. Download and install latest Ruby from [ruby-lang.org](http://www.ruby-lang.org/en/downloads/)
2. If a version of Ruby beyond 1.9.2 is already installed and RubyGems is missing, get it from [rubygems.org](http://rubygems.org/pages/download)

## Install
### From source
1. Build: `gem build igc-kml.gemspec` 
2. Install locally: `gem install igc-kml-X-X-X.gem` 

### From RubyGems.org
1. `gem install igc-kml` 

## Usage
	
Convert one or more .igc files to .kml:

	% igc-kml <filepattern>

See help: 

	% igc-kml -h