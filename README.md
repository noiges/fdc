# FDC - The IGC flight data format converter
[![Build Status](https://secure.travis-ci.org/nokinen/fdc.png)](http://travis-ci.org/nokinen/fdc) [![Dependency Status](https://gemnasium.com/nokinen/igc-kml.png)](https://gemnasium.com/nokinen/igc-kml)

## About
The `fdc` tool is a platform independent command-line utility written in Ruby for converting files in the avionics [flight recorder data format](http://carrier.csi.cam.ac.uk/forsterlewis/soaring/igc_file_format/igc_format_2008.html) (IGC) to the [keyhole markup language](https://developers.google.com/kml/documentation/) (KML) for their display in Applications such as [Google Earth](earth.google.com).
### Utilized IGC record types
Right now, only the most important record types commonly utilized by paragliding FR are touched during conversion:
* A record (FR manufacturer and identification)
* H record (File header)
 * PLT - Pilot
 * CID - Competition ID
 * GTY - Glider Type
 * GID - GLider ID
 * CCL - Competition Class
 * SIT - Site
 * DTE - Date
* B record (Fix)
* L record (Logbook/comments)
 * Only those produced by Skytraxx 2.0 devices

> Note that an automatic conversion of all available H and L records in a IGC file was abandoned for the sake of output readability. However, the predifined formatting can easily be extended and changed if neccessary. 

### File structure of created KML document
The utility creates a `<gx:Track>` element from the B records, and uses A, H and L records to create metadata for the corresponding `<description>` element. By default, the barometrix altitude information from the B records is used, and the track is not clamped to the ground, nor extruded. However, this bevavior can be changed through the available command line options.

## Install
### Requirements

* Any OS (e.g. Windows, Linux, Mac OS X) with Ruby 1.9.3 installed (get it from [ruby-lang.org](http://www.ruby-lang.org/en/downloads/))

### The easy way
From your console (e.g. Terminal.app on Mac OS X or CMD.exe on Windows), enter the following:
	
	% gem install fdc
	
This is the primary and most convenient way to install the latest version of `fdc` through the `gem` utility that pulls the latest version from [Rubygems.org](http://rubygems.org).

### The hard way
If you are a developer and want to install from source, open your console and enter the following:

	% git clone git@github.com:nokinen/fdc.git
	% cd fdc
	% gem build fdc.gemspec
	% gem install fdc-X-X-X.gem
	
By doing so, you are cloning this repository to the current working directory of your shell session, build `fdc` via its .gemspec file, and install the built gem on your system.

## Usage
	
Convert one or more .igc files to .kml:

	% fdc <filepattern>

See help:

	% fdc -h
	
## Advanced usage
### Skytraxx synchronization
On Unix-like systems, `fdc` and `rsync` can be used to setup aliases to conveniently synchronize your [Skytraxx 2.0](http://flugvario.de) device with your computer. 

The following instructions assume that the volume of your Skytraxx device is called `SKYTRAXX`, and that you sync `SKYTRAXX/FLIGHTS/` to `~/Flights`on your computer.

#### Bash
If you are using bash (the default shell on most Linux systems as well as Mac OS X), add the following line to your `.bashrc` file:

	alias skytraxx="rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; find ~/Flights -type f -name \*.igc | xargs fdc"
	
If you don't know where this file is, or how to edit it, simply execute the following command:

	% echo "alias skytraxx=\"rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; find ~/Flights -type f -name \*.igc | xargs fdc\"" >> ~/.bashrc

#### Zsh
If your are using a shell that supports recursive globbing (e.g. zsh or fish) the alias can be further simplified to:
	
	alias skytraxx="rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; fdc ~/Flights/**/*.igc"

#### Using the alias
After you succesfully added the `skytraxx` alias to your shell, you are able to synchronize all new IGC files from a connected skytraxx device to `~/Flights` and automatically convert them to the KML format. To do so, simply execute the following from your console:

	% skytraxx