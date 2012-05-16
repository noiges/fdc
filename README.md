# igc-kml
A Ruby tool for converting IGC files to KML.

## Requirements

At least ruby 1.8.7, running on a unix or linux system.

## Usage
See help:

	ruby igc-kml.rb
	
Convert one or more IGC files to KML:

	ruby igc-kml.rb <filepattern>
	
Convert IGC files to KML with alternative destination directory:

	ruby igc-kml.rb -d DEST <filepattern>
	
Convert IGC file to KML and output on STDOUT:

	ruby igc-kml.rb -s <filepattern>
