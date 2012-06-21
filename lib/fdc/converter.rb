require 'date'
require 'pathname'
require 'builder'
require 'fdc/utilities'
require 'fdc/exceptions'

# Class to convert IGC files to KML.
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

  # FileLoader mixing
  include Fdc::FileLoader

  # The compiled KML document
  attr_reader :kml

  # Load and parse an IGC file from the supplied path.
  # 
  # @param [String] file The path to the IGC file
  # @param [String] encoding The encoding of the input file
  # @raise [Fdc::FileReadError] If file could not be loaded
  # @raise [Fdc::FileFormatError] If the file format is invalid
  def parse(file, encoding="ISO-8859-1")
  
    # Do work
    load_file(file, encoding)
    parse_file
  
  end

  # Compile the KML document from the parsed IGC file.
  # 
  # @param [Boolean] clamp Whether the track should be clamped to the ground
  # @param [Boolean] extrude Whether the track should be extruded to the ground
  # @param [Boolean] gps Whether GPS altitude information should be used
  # @raise [RuntimeError] If {#parse} was not called before
  def compile(clamp=false, extrude=false, gps=false)
  
    # State assertion
    raise RuntimeError, "Cannot compile before successfull parse" if @igc.nil? or @date.nil?
  
    # Build HTML for balloon description
    html = Builder::XmlMarkup.new(:indent => 2)
    html.div :style => "width: 250;" do
      html.p do
        unless @a_records[3].nil? then 
          html.strong "Device:"
          html.dfn @a_records[3].strip
          html.br 
        end
      end
      html.p do
        @h_records.each do |h|
          if h.include? "PLT" and not h[2].strip.empty? then 
            html.strong "Pilot:"
            html.dfn h[2].strip
            html.br
          end
          if h.include? "CID" and not h[2].strip.empty? then 
            html.strong "Competition ID:"
            html.dfn h[2].strip
            html.br
          end
          if h.include? "GTY" and not h[2].strip.empty? then 
            html.strong "Glider:"
            html.dfn h[2].strip
            html.br
          end
          if h.include? "GID" and not h[2].strip.empty? then
            html.strong "Glider ID:"
            html.dfn h[2].strip
            html.br
          end
          if h.include? "CCL" and not h[2].strip.empty? then 
            html.strong "Competition class:"
            html.dfn h[2].strip
            html.br 
          end
          if h.include? "SIT" and not h[2].strip.empty? then 
            html.strong "Site:"
            html.dfn h[2].strip
            html.br
          end
        end
      
        html.strong "Date:"
        html.dfn @date[3..5].join(".")
        html.br
      end
    
      # Manufacturer-dependent L records
      case @a_records[1]
      when "XSX"
        @l_records.each do |l|
          if matches = l[1].scan(/(\w*):(-?\d+.?\d+)/) then 
            html.p do
              matches.each do |match|
                case match[0]
                when "MC"
                  html.strong "Max. climb:"
                  html.dfn match[1] << " m/s"
                  html.br
                when "MS"
                  html.strong "Max. sink:"
                  html.dfn match[1] << " m/s"
                  html.br
                when "MSP"
                  html.strong "Max. speed:"
                  html.dfn match[1] << " km/h"
                  html.br
                when "Dist"
                  html.strong "Track distance:"
                  html.dfn match[1] << " km"
                  html.br
                end
              end
            end
          end
        end
      end
    
    end
  
    # Build KML
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.kml "xmlns" => "http://www.opengis.net/kml/2.2", "xmlns:gx" => "http://www.google.com/kml/ext/2.2" do
      xml.Placemark {
        xml.name @path.basename(@path.extname)
        xml.Snippet :maxLines => "2" do
          xml.text! snippet
        end
        xml.description do
          xml.cdata! html.target!
        end
        xml.Style do
          xml.IconStyle do
            xml.Icon do 
              xml.href "http://earth.google.com/images/kml-icons/track-directional/track-0.png"
            end
          end
          xml.LineStyle do
            xml.color "99ffac59"
            xml.width "4"
          end
        end
        xml.gx:Track do
        
          clamp ? xml.altitudeMode("clampToGround") : xml.altitudeMode("absolute")
          extrude ? xml.extrude("1") : xml.extrude("0")
        
          @b_records.each do |b_record|
             time = DateTime.new(2000 + @date[5].to_i, @date[4].to_i, @date[3].to_i, 
              b_record[1].to_i, b_record[2].to_i, b_record[3].to_i)
             xml.when time
          end
          @b_records.each do |b_record|
            coords = Fdc::GeoLocation.to_dec(b_record[5], b_record[4])
            gps ? coords << b_record[8].to_f : coords << b_record[7].to_f
            xml.gx :coord, coords.join(" ")
          end
        end
      }
    end
  
    @kml = xml.target!
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
    raise RuntimeError, "Cannot export before compile was called" unless @kml
  
    dir = @path.dirname.to_s unless dir
  
    # Create Pathname for easier handling
    dest = Pathname.new(dir)
  
    # Create output file name
    dest += @path.basename(@path.extname)
  
    begin
      file = File.new(dest.to_s << ".kml", "w:UTF-8")
    rescue Errno::EACCES => e
      raise Fdc::FileWriteError, "Destination is write-protected: #{dir.to_s}"
    rescue Errno::ENOTDIR => e
      raise Fdc::FileWriteError, "Destination is not a directory: #{dir.to_s}"
    rescue Errno::ENOENT => e
      raise Fdc::FileWriteError, "Destination does not exist: #{dir.to_s}"
    end
  
    file.write(@kml)
    file.close
  
  end

  private

  # Regular expressions for file parsing
  REGEX_A = /^[a]([a-z\d]{3})([a-z\d]{3})?(.*)$/i
  REGEX_H = /^[h][f|o|p]([\w]{3})(.*):(.*)$/i
  REGEX_H_DTE = /^hf(dte)((\d{2})(\d{2})(\d{2}))/i
  REGEX_B = /^(B)(\d{2})(\d{2})(\d{2})(\d{7}[NS])(\d{8}[EW])([AV])(\d{5})(\d{5})/
  REGEX_L = /^l([a-z0-9]{3}|[plt]|[pfc])(.*)/i

  # Parse igc file content
  def parse_file
  
    begin
  
      # parse utc date
      @date = @igc.match(REGEX_H_DTE)
      raise Fdc::FileFormatError, "Invalid file format - header date is missing: #{@path.to_s}" unless @date
  
      # parse a records
      @a_records = @igc.match(REGEX_A)
      raise Fdc::FileFormatError, "Invalid file format: #{@path.to_s}" unless @a_records
  
      # parse h records
      @h_records = @igc.scan(REGEX_H)
  
      # parse b records
      @b_records = @igc.scan(REGEX_B)
  
      # parse l records
      @l_records = @igc.scan(REGEX_L)
  
    rescue ArgumentError => e
      raise Fdc::FileFormatError, "Wrong file encoding: #{e.message}"
    end
  
  end

  # Generate Snippet tag content
  def snippet
    summary = "Flight"
    @h_records.each do |h|
      if h.include? "SIT" and not h[2].strip.empty? then 
        summary << " from #{h[2].strip}" 
      end
    end
    summary << " on #{@date[3..5].join(".")}"
  end

end