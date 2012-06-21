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
   
   # Helper functions for file loading
   module FileLoader
     
     def load_file(file, encoding)
       
       @path = Pathname.new(file)
       @encoding = encoding
       
       raise Fdc::FileReadError, "Invalid file extension: #{@path.to_s}" unless @path.extname == ".igc"

       # Load file
       begin
        file = File.new(@path, "r", :encoding => @encoding)
       rescue Errno::EISDIR => e
        raise Fdc::FileReadError, "Input file is a directory: #{@path.to_s}"
       rescue Errno::ENOENT => e
        raise Fdc::FileReadError, "Input file does not exist: #{@path.to_s}"
       end

       @igc = file.read
       file.close
     end
     
   end
  
end