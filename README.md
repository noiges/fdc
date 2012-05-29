# igc-kml
A Ruby tool for converting IGC files to KML.

## Requirements

* Ruby 1.9.3
* Rubygem builder 3.0.0

## Setup

1. Download and install ruby from [ruby-lang.org](http://www.ruby-lang.org/en/downloads/)
2. Open your console and execute `gem install builder`

## Usage
Plot usage:

	ruby igc-kml.rb
	
Convert one or more IGC files to KML:

	ruby igc-kml.rb <filepattern>
	
Convert IGC files to KML with alternative destination directory:

	ruby igc-kml.rb -d DEST <filepattern>
	
Convert IGC file to KML and output on STDOUT:

	ruby igc-kml.rb -s <filepattern>
	
Clamp to ground:

	ruby igc-kml.rb -c <filepattern>
	
Extrude to ground:

	ruby igc-kml.rb -e <filepattern>

Use gps altitude instead of barometric altitude:

	ruby igc-kml.rb -g <filepattern>