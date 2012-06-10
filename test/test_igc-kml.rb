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
  
  def test_io
    
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
  
  def test_parse_and_compile
    
    # No A record
    assert_raise IgcKml::FileFormatError do
      @converter.parse "test/data/mod/no_a_record.igc"
      @converter.compile
    end
    
    # No B records
    assert_nothing_raised do
      @converter.parse "test/data/mod/no_b_records.igc"
      @converter.compile
    end
    
    # No H records and therefore no date
    assert_raise IgcKml::FileFormatError do
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
    
    # Output to STDOUT
    stdout = `bin/igc-kml -s test/data/orig/skytraxx.igc`
    assert(stdout.include?("</kml>"), "STDOUT does not contain kml tag")
    
    # Clamp
    assert(stdout.include?("<altitudeMode>absolute</altitudeMode>"), "altitudeMode should be absolute")
    stdout = `bin/igc-kml -s -c test/data/orig/skytraxx.igc`
    assert(stdout.include?("<altitudeMode>clampToGround</altitudeMode>"), "altitudeMode should be clampToGround")
    
    # Extrude
    assert(stdout.include?("<extrude>0</extrude>"), "Extrude should be 0")
    stdout = `bin/igc-kml -s -e test/data/orig/skytraxx.igc`
    assert(stdout.include?("<extrude>1</extrude>"), "Extrude should be 1")
    
  end
  
end