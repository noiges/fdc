require 'test/unit'
require 'igc-kml'

class IGCConverterTest < Test::Unit::TestCase
  
  def setup
    # Remove writing permission from orig/ directory
    `chmod -w test/data/orig`
    
    # Delete temp/ directory
    `rm -rf test/data/temp`
    
    # Recreate temp/ output directory
    `mkdir test/data/temp`
    
    @converter = IGCConverter.new
  end
  
  def teardown
    # Reset writing permission for orig/ directory
    `chmod +w test/data/orig`
    
    # Clean temp/ directory
    `rm -rf test/data/temp`
  end
  
  def test_errors
    
    # RuntimeError: compile and export called before load
    assert_raise RuntimeError do
      @converter.compile
    end
    assert_raise RuntimeError do
      @converter.export
    end
    
    # FileLoadingError: Invalid file extension (File does not end with .igc)
    assert_raise IgcKml::FileLoadingError do
      @converter.parse "test/data/orig/flytec.jpg"
    end
    
    # FileLoadingError: Input file is a directory
    assert_raise IgcKml::FileLoadingError do 
      @converter.parse "test/data/"
    end
    
    # FileLoadingError: Input file does not exist
    assert_raise IgcKml::FileLoadingError do
       @converter.parse "test/data/foo.igc"
    end
    
    # FileFormatError: Invalid file format (No A record can be found)
    assert_raise IgcKml::FileFormatError do
      @converter.parse "test/data/test_no_a_record.igc"
    end
    
    @converter.parse "test/data/orig/flytec.igc"
    @converter.compile
    
    # FileWritingError: Destination does not exist
    assert_raise IgcKml::FileWritingError do
      @converter.export "test/data/foo"
    end
    
    # FileWritingError: Destination is not a directory
    assert_raise IgcKml::FileWritingError do 
      @converter.export "test/data/flytec.igc"
    end
    
    # FileWritingError: Destination is write protected
    assert_raise IgcKml::FileWritingError do 
      @converter.export "test/data/orig"
    end
      
    # TODO FileFormatError: Wrong file encoding
    
  end
  
  def test_parsing
    # TODO Implement
  end
  
end

class CLITest < Test::Unit::TestCase
  
  def setup
    # Remove writing permission from orig/ directory
    `chmod -w test/data/orig`
    
    # Delete temp/ directory
    `rm -rf test/data/temp`
    
    # Recreate temp/ output directory
    `mkdir test/data/temp`
    
  end
  
  def teardown
    # Reset writing permission for orig/ directory
    `chmod +w test/data/orig`
    
    # Clean temp/ directory
    `rm -rf test/data/temp`
  end
  
  def test_exit_codes
    
    # Missing argument exit status
    stderr = `bin/igc-kml -d 2>&1`
    assert_equal(255, $?.exitstatus, stderr)
    
    # Invalid option exit status
    stderr = `bin/igc-kml -p 2>&1`
    assert_equal(254, $?.exitstatus, stderr)
    
    # File write exit status
    stderr = `bin/igc-kml test/data/orig/skytraxx.igc 2>&1`
    assert_equal(253, $?.exitstatus, stderr)
    
    stderr = `bin/igc-kml -d test/data/foo test/data/orig/skytraxx.igc 2>&1`
    assert_equal(253, $?.exitstatus, stderr)

    stderr = `bin/igc-kml -d test/data/orig/flytec.igc test/data/orig/skytraxx.igc 2>&1`
    assert_equal(253, $?.exitstatus, stderr)
    
    # No options
    `bin/igc-kml 2>&1`
    assert($?.success?, "Execution with no options fails")
    
    # Converting all sample files
    stderr = `bin/igc-kml -d test/data/temp test/data/orig/* 2>&1`
    assert($?.success?, stderr)
    
    # Try to convert all files in directory that has no IGC files
    stderr = `bin/igc-kml test/data/temp/* 2>&1`
    assert($?.success?, stderr)
  end
  
  def test_options
    
    # Verbose output
    stderr = `bin/igc-kml -d test/data/temp test/data/orig/skytraxx.igc 2>&1`
    assert(!stderr.include?("test/data/orig/skytraxx.igc"), stderr)
    stderr = `bin/igc-kml -v -d test/data/temp test/data/orig/skytraxx.igc 2>&1`
    assert(stderr.include?("test/data/orig/skytraxx.igc"), stderr)
    
  end
  
end