# The IGC flight data format converter
[![Build Status](https://secure.travis-ci.org/nokinen/fdc.png)](http://travis-ci.org/nokinen/fdc) [![Dependency Status](https://gemnasium.com/nokinen/fdc.png)](https://gemnasium.com/nokinen/fdc)

## About
The `fdc` tool is a platform independent command-line utility written in Ruby for converting files in the avionics [flight recorder data format](http://carrier.csi.cam.ac.uk/forsterlewis/soaring/igc_file_format/igc_format_2008.html) (IGC) to the [keyhole markup language](https://developers.google.com/kml/documentation/) (KML) for their display in Applications such as [Google Earth](earth.google.com).

## Requirements
The `fdc`tool can run on any operating system that has at least Ruby 1.9.1 installed. The latest version of the Ruby programming languate can be downloaded from [ruby-lang.org](http://www.ruby-lang.org/en/downloads/).

## Install
To install the latest version from [Rubygems.org](http://rubygems.org), enter the following from your console:
	
	% gem install fdc

## Usage
	
* Convert two files to KML: `fdc file1.igc file2.igc`
* Save converted file to alternative output dir: `fdc -d dest/dir src/dir/file.igc`
* Convert all files in the current working directory and extrude track to ground: `fdc -e *`
* Use gps altitude for all files in current working directory: `fdc -g *`
* Display usage for more options: `fdc` or `fdc -h`
	
### Skytraxx 2.0 synchronization
On Unix-like systems, `fdc` and `rsync` can be used to setup aliases to conveniently synchronize a [Skytraxx 2.0](http://flugvario.de) device and a computer. Assuming that the mounted volume of the connected device is `/Volumes/SKYTRAXX`, and the destination folder on the computer is `~/Flights`, the following script must be executed from the console:

	% echo "alias skytraxx=\"rsync -rv /Volumes/SKYTRAXX/FLIGHTS/ ~/Flights; find ~/Flights -type f -name \*.igc | xargs fdc\"" >> ~/.bashrc

After adding this alias to the shell, new files on the device can be synchronized with the computer and automatically converted by simply invoking `skytraxx` from the console.

## Information for developers
### Install from source
If you are a developer and want to install from source, open your console and enter the following:

	% git clone git@github.com:nokinen/fdc.git
	% cd fdc
	% gem build fdc.gemspec
	% gem install fdc-X-X-X.gem

### Utilized IGC record types
The full specification of the IGC data file standard can be found in Appendix A of the [Technical Specification for IGC-approved GNSS Flight Recorders](http://www.fai.org/component/phocadownload/category/855-technical_specifications?download=3165:technical-specification-for-igc-approved-gnss-flight-recorders). A HTML reference of the 2008 spec was created by Ian Forster-Lewis and is available [here](http://carrier.csi.cam.ac.uk/forsterlewis/soaring/igc_file_format/igc_format_2008.html). Right now, only the most important record types commonly utilized by paragliding FR are touched during conversion:
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