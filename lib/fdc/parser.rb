# Class for parsing IGC record types
class Fdc::Parser
  
  attr_reader :date_record
  attr_reader :a_record
  attr_reader :h_records
  attr_reader :b_records
  attr_reader :l_records
  
  # Parse the supplied IGC file content
  # 
  # @param [String] igc_file The IGC file content
  # @raise [Fdc::FileFormatError] If the file format is invalid
  def parse(igc_file)
    
    begin
      # parse utc date
      @date_record = igc_file.match(REGEX_H_DTE)
      raise Fdc::FileFormatError, "Invalid file format - header date is missing" unless @date_record
  
      # parse a records
      @a_record = igc_file.match(REGEX_A)
      raise Fdc::FileFormatError, "Invalid file format" unless @a_record
  
      # parse h records
      @h_records = igc_file.scan(REGEX_H)
  
      # parse b records
      @b_records = igc_file.scan(REGEX_B)
  
      # parse l records
      @l_records = igc_file.scan(REGEX_L)
    rescue ArgumentError => e
      raise Fdc::FileFormatError, "Wrong file encoding: #{e.message}"
    end
    
  end
  
  private
  
  # Regular expressions for parsing igc records
  REGEX_A = /^[a]([a-z\d]{3})([a-z\d]{3})?(.*)$/i
  REGEX_H = /^[h][f|o|p]([\w]{3})(.*):(.*)$/i
  REGEX_H_DTE = /^hf(dte)((\d{2})(\d{2})(\d{2}))/i
  REGEX_B = /^(B)(\d{2})(\d{2})(\d{2})(\d{7}[NS])(\d{8}[EW])([AV])(\d{5})(\d{5})/
  REGEX_L = /^l([a-z0-9]{3}|[plt]|[pfc])(.*)/i
  
end