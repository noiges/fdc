#!/usr/bin/ruby
require 'rubygems'
require 'builder'
require 'date'
require 'optparse'

ERROR_NO_SUCH_FILE_DIR = -1
ERROR_DIRECTORY = -2

REGEX_A = /^[a]([a-z\d]{3})([a-z\d]{3})?(.*)$/i
REGEX_H = /^[h][f|o|p]([\w]{3})(.*):(.*)$/i
REGEX_H_DTE = /^hf(dte)((\d{2})(\d{2})(\d{2}))/i
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
  
  def initialize(path)
    load_igc(path)
  end
  
  def load_igc(path)
    
    # Load file
    file = File.new(path, "r")
    @igc = file.read
    file.close
    
    # Match filename and path
    matches = path.match(/^((\.?\/)?(.+\/)*)((\w{8})(\.igc)*)$/)
    
    # Matches all of the following:
    #     /Users/nokinen/Code/github/igc-kml/sample/25GXXXX1.igc
    #     /Users/nokinen/Code/github/igc-kml/sample/25GXXXX1
    #     /Users/nokinen/Code/github/igkientb/sample/25GXXXX1
    #     ./sample/25GXXXX1.igc
    #     ./25GXXXX1.igc
    #     ./sample/25GXXXX1
    #     sample/25GXXXX1.igc
    #     25GXXXX1.igc
    #     25GXXXX1
    #
    # Match 1: path without filename and extension
    # Match 5: filename without extension
    
    @path = matches[1]
    @filename = matches[5]
    
    parse_igc
    build_kml
    
  end
  
  def save_kml(path = @path)
    
    if @kml
       if path.match(/.$/) == "/"
         file = File.new(path << @filename << ".kml", "w")
       else
         file = File.new(path << "/" << @filename << ".kml", "w")
       end
       file.write(@kml)
       file.close
     else
       raise LoadError "No igc loaded"
    end
    
  end
  
  private

  def parse_igc
    # parse utc date with groups HFDTE DD MM YY
    @date = @igc.match(REGEX_H_DTE)
    
    # parse a records
    @a_records = @igc.match(REGEX_A)
    
    # parse h records
    @h_records = @igc.scan(REGEX_H)
    
    # parse b records with groups B HH MM SS DDMMmmm N/S DDDMMmmm E/W A/V PPPPP GGGGG
    @b_records = @igc.scan(/^(B)(\d{2})(\d{2})(\d{2})(\d{7}[NS])(\d{8}[EW])([AV])(\d{5})(\d{5})/)
    
    # parse l records
    @l_records = @igc.scan(REGEX_L)
    
  end

  def build_kml
    
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.kml "xmlns" => "http://www.opengis.net/kml/2.2", "xmlns:gx" => "http://www.google.com/kml/ext/2.2" do
      xml.Placemark {
        xml.name @filename
        xml.description do
          
          description = String.new
          
          # Required
          description << @a_records[3] unless @a_records[3].nil?
          description << @date.to_a[1..2].join(": ") << "\n"

          @h_records.each do |h_record|
            description << h_record[0] << ":" << h_record[2]
          end
          
          @l_records.each do |l_record|
            case l_record[0]
            when "XSX"
              l_record[1].split(";").each do |l|
                description << l << "\n" 
              end
            end
          end
          
          xml.cdata! description
        end
        xml.gx:Track do
          xml.altitudeMode "absolute"
          @b_records.each do |b_record|
             time = DateTime.new(2000 + @date[5].to_i, @date[4].to_i, @date[3].to_i, 
               b_record[1].to_i, b_record[2].to_i, b_record[3].to_i)
             xml.when time
          end
          @b_records.each do |b_record|
             coords = Location.to_dec(b_record[4..5]) << b_record[8].to_f
             xml.gx :coord, coords.join(" ")
          end
        end
      }
    end
    
    @kml = xml.target!
    
  end

end

if __FILE__ == $0
  
  options = {}
  
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: igc-kml.rb [OPTIONS] FILEPATTERN…"
    
    opts.separator ""
    opts.separator "Options:"
    
    # Define alternative destination directory
    options[:dest] = nil
    opts.on( '-d', '--destination DEST', String, 'Alternative destination directory for converted KML files' ) do |dest| 
     options[:dest] = dest
    end
    
    # Define alternative destination directory
    options[:stdout] = false
    opts.on( '-s', '--stdout', String, 'Print converted KML to STDOUT' ) do
     options[:stdout] = true
    end
    
    # Define help
    opts.on_tail( '-h', '--help', 'Display this help screen' ) do
      puts opts
      exit
    end

  end
  
  optparse.parse!
  
  puts optparse if ARGV.empty?
  
  ARGV.each do |file|
    begin
      converter = Converter.new(file)
    rescue Errno::EISDIR => e
      puts e.message
      exit(ERROR_DIRECTORY)
    rescue Errno::ENOENT => e
      puts e.message
      exit(ERROR_NO_SUCH_FILE_DIR)
    end
    
    if options[:stdout] 
      STDOUT.puts converter.kml
    elsif
      options[:dest] ? converter.save_kml(options[:dest]) : converter.save_kml
    end
  end
  
end