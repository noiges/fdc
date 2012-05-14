#!/usr/bin/ruby
require 'rubygems'
require 'builder'

module Location
  
  def Location.to_decimal(sexagesimal)
    raise NotImplementedError
  end

  def Location.to_sexagesimal(decimal)
    raise NotImplementedError
  end
  
end

module Kml

  def Kml.compile
    
    coords = "13.638834,47.360322,1896 13.652310,47.374340,1235"

    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.kml "xmlns" => "http://www.opengis.net/kml/2.2" do
      xml.Document do
        xml.Placemark do
          xml.LineString do
            xml.altitudeMode "absolute"
            xml.coordinates coords
          end
        end
      end
    end
    
  end
  
end

def read_igc(filepath)
  file = File.new(filepath, "r")
  while (line = file.gets)
      puts "#{line}"
  end
  file.close
end

puts read_igc "sample/25EXXXX2.igc"
puts Kml.compile