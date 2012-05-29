require 'builder'
require 'date'
require 'pathname'

ERROR_MISSING_ARGUMENT = -1
ERROR_INVALID_OPTION = -2
ERROR_DEST_NOT_A_DIRECTORY = -3
ERROR_WRITE_PERMISSION = -4

REGEX_A = /^[a]([a-z\d]{3})([a-z\d]{3})?(.*)$/i
REGEX_H = /^[h][f|o|p]([\w]{3})(.*):(.*)$/i
REGEX_H_DTE = /^hf(dte)((\d{2})(\d{2})(\d{2}))/i
REGEX_B = /^(B)(\d{2})(\d{2})(\d{2})(\d{7}[NS])(\d{8}[EW])([AV])(\d{5})(\d{5})/
REGEX_L = /^l([a-z0-9]{3}|[plt]|[pfc])(.*)/i

module Location
  
  # Convert from MinDec to Dec notation
  def Location.to_dec(mindec)
    
    lat = mindec[0].match(/^(\d{2})((\d{2})(\d{3}))(N|S)/)
    long = mindec[1].match(/^(\d{3})((\d{2})(\d{3}))(E|W)/)
    
    # Convert minutes to decimal
    lat_dec = lat[1].to_f + (lat[2].to_f / 1000 / 60)
    long_dec = long[1].to_f + (long[2].to_f / 1000 / 60)
    
    # Change signs according to direction
    lat_dec *= (-1) if long[5] == "S"
    long_dec *= (-1) if long[5] == "W"
    
    dec = [long_dec, lat_dec]

  end

  # Convert from Dec to MinDec notation
  def Location.to_mindec(dec)
    raise NotImplementedError
  end
  
end

class Converter
  
  attr_accessor :kml
  
  def initialize(path, clamp=false, extrude=false, gps=false)
    
    @path = Pathname.new(path)
    @clamp = clamp
    @extrude = extrude
    @gps = gps
    
    if @path.directory?
      raise LoadError, "Not a file but directory - " << @path
    elsif @path.extname == ".igc"
      load_igc(@path)
    else
      raise LoadError, "Cannot read files of that type - " << @path
    end
  end
  
  def save_kml(dirname = @path.dirname)
    if File.directory?(dirname)
      dirname += @path.basename(@path.extname)
      file = File.new(dirname.to_s << ".kml", "w")
      file.write(@kml)
      file.close
    else
      raise IOError, "Destination is not a directory - " << dirname
    end
  end
  
  private
  
  def load_igc(path)

     # Load file
     file = File.new(path, "r")
     @igc = file.read
     file.close

     parse_igc
     build_kml

   end

  def parse_igc
    # parse utc date
    @date = @igc.match(REGEX_H_DTE)
    
    # parse a records
    @a_records = @igc.match(REGEX_A)
    raise LoadError, 'Invalid file format - ' << @path unless @a_records
    
    # parse h records
    @h_records = @igc.scan(REGEX_H)
    
    # parse b records
    @b_records = @igc.scan(REGEX_B)
    
    # parse l records
    @l_records = @igc.scan(REGEX_L)
    
  end

  def build_kml
    
    # Build HTML for description
    html = Builder::XmlMarkup.new(:indent => 2)
    html.div :style => "width: 250;" do
      html.p do
        unless @a_records[3].nil? then html.strong "Device:"; html.dfn @a_records[3].strip; html.br end
      end
      html.p do
        @h_records.each do |h|
          if h.include?("PLT") && !h[2].strip.empty? then html.strong "Pilot:"; html.dfn h[2].strip; html.br end
          if h.include?("CID") && !h[2].strip.empty? then html.strong "Competition ID:"; html.dfn h[2].strip; html.br end
          if h.include?("GTY") && !h[2].strip.empty? then html.strong "Glider:"; html.dfn h[2].strip; html.br end
          if h.include?("GID") && !h[2].strip.empty? then html.strong "Glider ID:"; html.dfn h[2].strip; html.br end
          if h.include?("CCL") && !h[2].strip.empty? then html.strong "Competition class:"; html.dfn h[2].strip; html.br end
          if h.include?("SIT") && !h[2].strip.empty? then html.strong "Site:"; html.dfn h[2].strip; html.br end
        end
        html.strong "Date:"; html.dfn @date[3..5].join("."); html.br
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
            coords = Location.to_dec(b_record[4..5])
            @gps ? coords << b_record[8].to_f : coords << b_record[7].to_f
            xml.gx :coord, coords.join(" ")
          end
        end
      }
    end
    
    @kml = xml.target!
    
  end
  
  def snippet
    summary = "Flight from "
    @h_records.each do |h|
      if h.include?("SIT") && !h[2].strip.empty? then summary << h[2].strip << " on " end
    end
    summary << @date[3..5].join(".")
  end

end