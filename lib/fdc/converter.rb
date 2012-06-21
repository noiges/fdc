require 'pathname'

require 'fdc/utilities'
require 'fdc/exceptions'
require 'fdc/parser'
require 'fdc/compiler'

# Convert IGC Files to KML
# 
# @!attribute [r] kml
#   @return [String] The KML document
# 
# @example
#   converter = Converter.new
#   converter.parse(path/to/file.igc)
#   converter.compile
#   converter.export(output/dir)
class Fdc::Converter

  # Mixins
  include Fdc::FileLoader
  include Fdc::FileWriter
  
  def initialize
    @parser = Fdc::Parser.new
    @compiler = Fdc::Compiler.new @parser
  end

  # Load and parse an IGC file from the supplied path.
  # 
  # @param [String] file The path to the IGC file
  # @param [String] encoding The encoding of the input file
  # @raise [Fdc::FileReadError] If file could not be loaded
  # @raise [Fdc::FileFormatError] If the file format is invalid
  def parse(file, encoding="ISO-8859-1")
    
    path = Pathname.new(file)
    load(path, encoding)
    raise Fdc::FileReadError, "Invalid file extension: #{path.to_s}" unless path.extname == ".igc"
    @parser.parse @file
  
  end

  # Compile the KML document from the parsed IGC file.
  # 
  # @param [Boolean] clamp Whether the track should be clamped to the ground
  # @param [Boolean] extrude Whether the track should be extruded to the ground
  # @param [Boolean] gps Whether GPS altitude information should be used
  # @raise [RuntimeError] If {#parse} was not called before
  def compile(clamp=false, extrude=false, gps=false)
  
    # State assertion
    raise RuntimeError, "Cannot compile without preceding parse" unless @parser.ready?
    
    name = @path.basename(@path.extname)
    @compiler.compile name, clamp, extrude, gps
  
  end

  # Export the compiled KML document
  # 
  # @param [String] dir The alternative output directory. 
  #   If nothing is supplied the files are written to the same location 
  #   as the IGC input file.
  # @raise [RuntimeError] If {#parse} and {#compile} were not called before
  # @raise [Fdc::FileWriteError] If dirname is not a directory or write protected
  def export(dir = nil)
  
    # Assert state
    raise RuntimeError, "Cannot export before compile was called" unless @compiler.kml
  
    dir = @path.dirname.to_s unless dir
    write Pathname.new(dir) + (@path.basename(@path.extname).to_s << ".kml"), @compiler.kml
  
  end
  
  # Get the compiled KML document
  # @return [String] The compiled KML document
  def kml
    @compiler.kml
  end

end