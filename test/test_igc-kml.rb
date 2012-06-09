require 'test/unit'
require 'igc-kml'

class IGCConverterTest < Test::Unit::TestCase
  
  def setup
    `chmod -w test/data/orig`
  end
  
  def test_errors
    # FileLoadingError: Invalid file extension (File does not end with .igc)
    assert_raise(IgcKml::FileLoadingError) { Converter.new("test/data/orig/flytec.jpg") }
    
    # FileLoadingError: Input file is a directory
    assert_raise(IgcKml::FileLoadingError) { Converter.new("test/data/") }
    
    # FileLoadingError: Input file does not exist
    assert_raise(IgcKml::FileLoadingError) { Converter.new("test/data/foo.igc") }
    
    # FileFormatError: Invalid file format (No A record can be found)
    assert_raise(IgcKml::FileFormatError) { Converter.new("test/data/test_no_a_record.igc") }
    
    converter = Converter.new("test/data/orig/flytec.igc")
    # FileWritingError: Destination does not exist
    assert_raise IgcKml::FileWritingError do converter.save_kml "test/data/foo" end
    # FileWritingError: Destination is not a directory
    assert_raise IgcKml::FileWritingError do converter.save_kml "test/data/flytec.igc" end
    # FileWritingError: Destination is write protected
    assert_raise IgcKml::FileWritingError do converter.save_kml "test/data/orig" end
      
    # TODO FileFormatError: Wrong file encoding
    
  end
  
  def test_parsing
    # TODO Implement
  end
  
  def test_cli
    
    # Missing argument exit status
    `bin/igc-kml -d`
    assert_equal(255, $?.exitstatus)
    
    # Invalid option exit status
    `bin/igc-kml -p`
    assert_equal(254, $?.exitstatus)
    
    # File write exit status
    `bin/igc-kml test/data/orig/skytraxx.igc`
    assert_equal(253, $?.exitstatus)
    
    `bin/igc-kml -d test/data/foo test/data/orig/skytraxx.igc`
    assert_equal(253, $?.exitstatus)

    `bin/igc-kml -d test/data/orig/flytec.igc test/data/orig/skytraxx.igc`
    assert_equal(253, $?.exitstatus)
    
    # No options
    `bin/igc-kml`
    assert($?.success?, "Execution with no options fails")
    
    # Converting all sample files
    `bin/igc-kml -d test/data/temp test/data/orig/*`
    assert($?.success?)
  end
  
end