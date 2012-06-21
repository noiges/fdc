require 'pathname'
require 'fdc/exceptions'

# Utility modules used by {Fdc::Converter}
module Fdc
  
   # Helper functions for geocoordinate conversion
   module GeoLocation

     # Convert geocoordinates from mindec notation of IGC to dec notation
     # 
     # @param [String] long The longitude from the igc file
     # @param [String] lat  The Latitude from the igc file
     # @return [Float, Float] Longitude and Latitude in decimal notation
     # @example Convert a pair of coordinates
     #   GeoLocation.to_dec("01343272E", "4722676N")  #=>[13.7212,47.37793333333333]
     def GeoLocation.to_dec(long, lat)

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
   
   # Common file loading operations
   module FileLoader
     
     # Loaded file content
     attr_reader :file
     
     # Loaded file path
     attr_reader :path
     
     # Loaded file encoding
     attr_reader :encoding
     
     private
     
     # Load a file from the supplied path
     # 
     # @param [Pathname] path The path to the file
     # @param [String] encoding The encoding of the file
     # @raise [Fdc::FileReadError] If file could not be loaded
     def load(path, encoding)
       
       # The path of the file
       @path = path
       
       # The file encoding
       @encoding = encoding

       # Load file
       begin
        f = File.new(@path, "r", :encoding => @encoding)
        @file = f.read
       rescue Errno::EISDIR => e
        raise Fdc::FileReadError, "Input file is a directory: #{@path.to_s}"
       rescue Errno::ENOENT => e
        raise Fdc::FileReadError, "Input file does not exist: #{@path.to_s}"
       ensure
         if f then f.close end
       end
     end
     
   end
   
   # Common file writing operations
   module FileWriter
     
     private
     # Write a file to the file system
     # 
     # @param [Pathname] path The path for the file
     # @param [String] data The data of the file
     # @raise [Fdc::FileWriteError] If dirname is not a directory or write protected
     def write(path, data)
       begin
         file = File.new(path, "w:UTF-8")
         file.write(data)
       rescue Errno::EACCES => e
         raise Fdc::FileWriteError, "Destination is write-protected: #{path.to_s}"
       rescue Errno::ENOTDIR => e
         raise Fdc::FileWriteError, "Destination is not a directory: #{path.to_s}"
       rescue Errno::ENOENT => e
         raise Fdc::FileWriteError, "Destination does not exist: #{path.to_s}"
       ensure 
         if file then file.close end
       end
     end
   end
  
end