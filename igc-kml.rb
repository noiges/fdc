#!/usr/bin/ruby
require 'rubygems'
require 'builder'
require 'date'

module Location
  
  # Convert from MinDec to Dec notation
  def Location.to_dec(mindec)
    
    lat = mindec[0].match(/^(\d{2})((\d{2})(\d{3}))(N|S)/)
    long = mindec[1].match(/^(\d{3})((\d{2})(\d{3}))(E|W)/)
    
    lat_dec = lat[1].to_f + (lat[2].to_f / 1000 / 60)
    lat_dec *= (-1) if long[5] == "S"
    long_dec = long[1].to_f + (long[2].to_f / 1000 / 60)
    long_dec *= (-1) if long[5] == "W"
    
    dec = [long_dec.to_f, lat_dec.to_f]

  end

  # Convert from Dec to MinDec notation
  def Location.to_mindec(dec)
    raise NotImplementedError
  end
  
end

class Converter
  
  attr_accessor :kml
  
  def initialize(igc_filepath)
    read_igc(igc_filepath)
    parse_igc
    build_kml
  end
  
  def write_kml(kml_filepath)
    raise NotImplementedError
  end
  
  private
  
  def read_igc(filepath)
    file = File.new(filepath, "r")
    @igc = file.read
    file.close
  end

  def parse_igc
    # parse utc date with groups HFDTE DD MM YY
    @date = @igc.match(/^(HFDTE)(\d{2})(\d{2})(\d{2})/)
    
    # parse b records with groups B HH MM SS DDMMmmm N/S DDDMMmmm E/W A/V PPPPP GGGGG
    @b_records = @igc.scan(/^(B)(\d{2})(\d{2})(\d{2})(\d{7}[NS])(\d{8}[EW])([AV])(\d{5})(\d{5})/)
  end

  def build_kml
    
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.kml "xmlns" => "http://www.opengis.net/kml/2.2", "xmlns:gx" => "http://www.google.com/kml/ext/2.2" do
      xml.Document { 
        # xml.name "Test"
        xml.Placemark {
          # xml.name "Test"
          xml.gx:Track do
            xml.altitudeMode "absolute"
            @b_records.each do |b_record|
               time = DateTime.new(2000 + @date[4].to_i, @date[3].to_i, @date[2].to_i, 
                 b_record[1].to_i, b_record[2].to_i, b_record[3].to_i)
               xml.when time
            end
            @b_records.each do |b_record|
               coords = Location.to_dec(b_record[4..5]) << b_record[8].to_f
               xml.gx :coord, coords.join(" ")
            end
          end
        }
      }
    end
    
    @kml = xml.target!
    
  end

end

converter = Converter.new("sample/25GXXXX1.igc")

file = File.new("test.kml", "w")
file.write(converter.kml)
file.close