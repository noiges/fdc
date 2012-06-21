# FDC - The IGC flight data format converter
[![Build Status](https://secure.travis-ci.org/nokinen/fdc.png)](http://travis-ci.org/nokinen/fdc) [![Dependency Status](https://gemnasium.com/nokinen/fdc.png)](https://gemnasium.com/nokinen/fdc)

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
	
* Convert files: `fdc <filepattern>`
* Convert to alternative output dir: `fdc -d dest/dir <filepattern>`
* Extrude track to ground: `fdc -e <filepattern>`
* Use gps altitude: `fdc -g <filepattern>`
* Display usage for more: `fdc` or `fdc -h`
	
## Skytraxx 2.0 synchronization
On Unix-like systems, `fdc` and `rsync` can be used to setup aliases to conveniently synchronize a [Skytraxx 2.0](http://flugvario.de) device and a computer. Assuming that the mounted volume of the connected device is `/Volumes/SKYTRAXX`, and the destination folder on the computer is `~/Flights`, the following script must be executed from the console:

	% echo "alias skytraxx=\"rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; find ~/Flights -type f -name \*.igc | xargs fdc\"" >> ~/.bashrc

After adding this alias to the shell, new files on the device can be synchronized with the computer and automatically converted by simply invoking `skytraxx` from the console.