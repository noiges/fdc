module Fdc

  # Exception caused by invalid input file format
  class FileFormatError < StandardError; end
  
  # Exception that is raised when a file cannot be read
  class FileReadError < StandardError; end
  
  # Exception that is raised when a files cannot be written
  class FileWriteError < StandardError; end

end