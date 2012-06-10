require 'test/unit'
require 'igc-kml'

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
    
    # TODO Incompatible ruby version
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