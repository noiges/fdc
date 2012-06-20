require 'test/unit'
require 'fdc'

class ConverterTest < Test::Unit::TestCase
  
  def setup
    # Remove writing permission from orig/ directory
    `chmod -w test/data/orig`
    
    # Delete temp/ directory
    `rm -rf test/data/temp`
    
    # Recreate temp/ output directory
    `mkdir test/data/temp`
    
    @converter = Fdc::Converter.new
  end
  
  def teardown
    # Reset writing permission for orig/ directory
    `chmod +w test/data/orig`
    
    # Clean temp/ directory
    `rm -rf test/data/temp`
  end
  
  def test_io
    
    # RuntimeError: compile and export called before load
    assert_raise RuntimeError do
      @converter.compile
    end
    assert_raise RuntimeError do
      @converter.export
    end
    
    # FileLoadingError: Invalid file extension (File does not end with .igc)
    assert_raise Fdc::FileLoadingError do
      @converter.parse "test/data/orig/flytec.jpg"
    end
    
    # FileLoadingError: Input file is a directory
    assert_raise Fdc::FileLoadingError do 
      @converter.parse "test/data/"
    end
    
    # FileLoadingError: Input file does not exist
    assert_raise Fdc::FileLoadingError do
       @converter.parse "test/data/foo.igc"
    end
    
    @converter.parse "test/data/orig/flytec.igc"
    @converter.compile
    
    # FileWritingError: Destination does not exist
    assert_raise Fdc::FileWritingError do
      @converter.export "test/data/foo"
    end
    
    # FileWritingError: Destination is not a directory
    assert_raise Fdc::FileWritingError do 
      @converter.export "test/data/flytec.igc"
    end
    
    # FileWritingError: Destination is write protected
    assert_raise Fdc::FileWritingError do 
      @converter.export "test/data/orig"
    end
      
    # TODO FileFormatError: Wrong file encoding
    
  end
  
  def test_parse_and_compile
    
    # No A record
    assert_raise Fdc::FileFormatError do
      @converter.parse "test/data/mod/no_a_record.igc"
      @converter.compile
    end
    
    # No B records
    assert_nothing_raised do
      @converter.parse "test/data/mod/no_b_records.igc"
      @converter.compile
    end
    
    # No H records and therefore no date
    assert_raise Fdc::FileFormatError do
      @converter.parse "test/data/mod/no_h_records.igc"
    end
    
    # No date must cause RuntimeError if compile is called
    assert_raise RuntimeError do
      @converter.compile
    end
    
    # No L records
    assert_nothing_raised do
      @converter.parse "test/data/mod/no_l_records.igc"
      @converter.compile
    end
    
    # Corrupt B records
    assert_nothing_raised do
      @converter.parse "test/data/mod/corrupt_b_records.igc"
      @converter.compile
    end
    
  end
  
end