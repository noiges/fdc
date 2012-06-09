# igc-kml [![Build Status](https://secure.travis-ci.org/nokinen/igc-kml.png)](http://travis-ci.org/nokinen/igc-kml) [![Dependency Status](https://gemnasium.com/nokinen/igc-kml.png)](https://gemnasium.com/nokinen/igc-kml)
A command-line tool written in Ruby for converting files in the avionics [flight recorder data format](http://carrier.csi.cam.ac.uk/forsterlewis/soaring/igc_file_format/igc_format_2008.html) (.igc) to the [keyhole markup language](https://developers.google.com/kml/documentation/) (.kml) for their display in Applications such as [Google Earth](earth.google.com).

## Requirements

* Ruby 1.9.3 (get it from [ruby-lang.org](http://www.ruby-lang.org/en/downloads/))

## Install
### The easy way
From your console (e.g. Terminal.app on Mac OS X or CMD.exe on Windows), enter the following:
	
	% gem install igc-kml
	
This is the primary and most convenient way to install the latest version of `igc-kml` through the `gem` utility that installs the latest version from [Rubygems.org](http://rubygems.org).

### The hard way
If your are a developer and want to install from source, open your console and enter the following:

	% git clone git@github.com:nokinen/igc-kml.git
	% cd igc-kml
	% gem build igc-kml.gemspec
	% gem install igc-kml-X-X-X.gem
	
By doing so, you are cloning this repository to the current working directory of your shell session, build igc-kml via its .gemspec file, and install the built gem on your system.

## Usage
	
Convert one or more .igc files to .kml:

	% igc-kml <filepattern>

See help:

	% igc-kml -h
	
## Advanced usage
### Skytraxx synchronization
On Unix-like systems, `igc-kml` and `rsync` can be used to setup aliases to conveniently synchronize your [Skytraxx 2.0](http://flugvario.de) device with your computer.
#### Bash
If you are using bash (the default shell on most Linux systems as well as Mac OS X), add the following line to your `.bashrc` file:

	alias skytraxx="rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; find ~/Flights -type f -name \*.igc | xargs igc-kml"
	
If you don't know where this file is, or how to edit it, simply execute the following command:

	% echo "alias skytraxx=\"rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; find ~/Flights -type f -name \*.igc | xargs igc-kml\"" >> ~/.bashrc

#### ZSH
With the ZSH shell on a Unix system, the `FLIGHTS` directory and the containing IGC files of  can be automatically synced and converted to KML by adding the following alias to your `.zshrc` file (assuming that your flights are stored in `~/Flights`, and the name of Skytraxx's volume is `SKYTRAXX`):

    alias skytraxx="rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; igc-kml ~/Flights/**/*.igc"