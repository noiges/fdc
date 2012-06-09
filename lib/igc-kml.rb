require 'date'
require 'pathname'
require 'builder'
require 'igc-kml/exceptions'

# Module with helper functions for geocoordinate conversion
module Location
  
  # Convert coordinates from mindec notation of IGC to dec notation
  # 
  # @param [String] long The longitude from the igc file
  # @param [String] lat  The Latitude from the igc file
  # @return [Float, Float] Longitude and Latitude in decimal notation
  # @example Convert a pair of coordinates
  #   Location.to_dec("01343272E", "4722676N")  #=>[13.7212,47.37793333333333]
  def Location.to_dec(long, lat)
    
    long_m = long.match(/^(\d{3})((\d{2})(\d{3}))(E|W)/)
    lat_m = lat.match(/^(\d{2})((\d{2})(\d{3}))(N|S)/)
    
    # Convert minutes to decimal
    long_dec = long_m[1].to_f + (long_m[2].to_f / 1000 / 60)
    lat_dec = lat_m[1].to_f + (lat_m[2].to_f / 1000 / 60)
    
    # Change signs according to direction
    long_dec *= (-1) if long_m[5] == "W"
    lat_dec *= (-1) if lat_m[5] == "S"
    
    return long_dec, lat_dec
  end
  
end

# After initialization, a Converter object loads a IGC file from disk, parses
# it, and creates the corresponding KML file.
# 
# @!attribute [r] kml
#   @return [String] The KML document
# 
# @example
#   converter = Converter.new "path/to/file.igc"
#   converter.save_kml
class Converter
  
  # The KML document
  attr_accessor :kml
  
  # Create a new Converter object, load and parse the IGC file and build the
  # KML document.
  # 
  # @param [String] path The path to the IGC file
  # @param [Boolean] clamp Whether the track should be clamped to the ground
  # @param [Boolean] extrude Whether the track should be extruded to the
  #   ground
  # @param [Boolean] gps Whether GPS altitude information should be used
  # @param [String] encodding The encoding of the input file
  # 
  # @raise [FileLoadingError] If the input file is not existent, a directory, 
  #   has the wrong extension or an invalid file format
  def initialize(path, clamp=false, extrude=false, gps=false, encoding="ISO-8859-1")

    @path = Pathname.new(path)
    @clamp = clamp
    @extrude = extrude
    @gps = gps
    @encoding = encoding

    load_igc(@path)

  end
  
  # Write the KML document to disk.
  # 
  # @param [Pathname] dirname The alternative output directory. If nothing is
  #   supplied the files are written to the same location as the IGC input
  #   file.
  # @raise [IgcKml::FileWritingError] If dirname is not a directory or write protected
  def save_kml(dirname = @path.dirname.to_s)
      
      # Create Pathname for easier handling
      dest = Pathname.new(dirname)
      
      # Create output file name
      dest += @path.basename(@path.extname)
      
      begin
        file = File.new(dest.to_s << ".kml", "w:UTF-8")
      rescue Errno::EACCES => e
        raise IgcKml::FileWritingError, "Destination is write-protected: " << dirname.to_s
      rescue Errno::ENOTDIR => e
        raise IgcKml::FileWritingError, "Destination is not a directory: "  << dirname.to_s
      rescue Errno::ENOENT => e
        raise IgcKml::FileWritingError, "Destination does not exist: " << dirname.to_s
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
  
  # Load igc file from supplied path
  def load_igc(path)

    raise IgcKml::FileLoadingError, "Invalid file extension: " << @path.to_s unless @path.extname == ".igc"

    # Load file
    begin
     file = File.new(path, "r", :encoding => @encoding)
    rescue Errno::EISDIR => e
     raise IgcKml::FileLoadingError, "Input file is a directory: " << path.to_s
    rescue Errno::ENOENT => e
     raise IgcKml::FileLoadingError, "Input file does not exist: " << path.to_s
    end

    @igc = file.read
    file.close

    parse_igc
    build_kml

   end
  
  # Parse igc file content
  def parse_igc
    
    begin
    
      # parse utc date
      @date = @igc.match(REGEX_H_DTE)
    
      # parse a records
      @a_records = @igc.match(REGEX_A)
      raise IgcKml::FileFormatError, 'Invalid file format: ' << @path.to_s unless @a_records
    
      # parse h records
      @h_records = @igc.scan(REGEX_H)
    
      # parse b records
      @b_records = @igc.scan(REGEX_B)
    
      # parse l records
      @l_records = @igc.scan(REGEX_L)
    
    rescue ArgumentError => e
      raise IgcKml::FileFormatError, "Wrong file encoding: " << e.message
    end
    
  end

  # Build kml from parsed data
  def build_kml
    
    # Build HTML for description
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
          if h.include?("PLT") && !h[2].strip.empty? then 
            html.strong "Pilot:"
            html.dfn h[2].strip
            html.br
          end
          if h.include?("CID") && !h[2].strip.empty? then 
            html.strong "Competition ID:"
            html.dfn h[2].strip
            html.br
          end
          if h.include?("GTY") && !h[2].strip.empty? then 
            html.strong "Glider:"
            html.dfn h[2].strip
            html.br
          end
          if h.include?("GID") && !h[2].strip.empty? then
            html.strong "Glider ID:"
            html.dfn h[2].strip
            html.br
          end
          if h.include?("CCL") && !h[2].strip.empty? then 
            html.strong "Competition class:"
            html.dfn h[2].strip
            html.br 
          end
          if h.include?("SIT") && !h[2].strip.empty? then 
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
        html.p do 
          @l_records[0][1].split(";").each do |value|
            key_val = value.split(":")
            case key_val[0]
            when "MC"
              html.strong "Max. climb:"
              html.dfn key_val[1].strip << " m/s"
              html.br
            when "MS"
              html.strong "Max. sink:"
              html.dfn key_val[1].strip << " m/s"
              html.br
            when "MSP"
              html.strong "Max. speed:"
              html.dfn key_val[1].strip << " km/h"
              html.br
            when "Dist"
              html.strong "Track distance:"
              html.dfn key_val[1].strip << " km"
              html.br
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
          
          @clamp ? xml.altitudeMode("clampToGround") : xml.altitudeMode("absolute")
          @extrude ? xml.extrude("1") : xml.extrude("0")
          
          @b_records.each do |b_record|
             time = DateTime.new(2000 + @date[5].to_i, @date[4].to_i, @date[3].to_i, 
              b_record[1].to_i, b_record[2].to_i, b_record[3].to_i)
             xml.when time
          end
          @b_records.each do |b_record|
            coords = Location.to_dec(b_record[5], b_record[4])
            @gps ? coords << b_record[8].to_f : coords << b_record[7].to_f
            xml.gx :coord, coords.join(" ")
          end
        end
      }
    end
    
    @kml = xml.target!
    
  end
  
  # Generate Snippet tag content
  def snippet
    summary = "Flight from "
    @h_records.each do |h|
      if h.include?("SIT") && !h[2].strip.empty? then 
        summary << h[2].strip << " on " 
      end
    end
    summary << @date[3..5].join(".")
  end

end