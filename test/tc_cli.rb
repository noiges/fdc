require "test/unit"

class TestCLI < Test::Unit::TestCase

  def test_error_codes
  
    system("ruby ../igc-kml.rb")
    assert($?.exitstatus == 0)
  
    system("ruby ../igc-kml.rb -h")
    assert($?.exitstatus == 0)
  
    system("ruby ../igc-kml.rb foo")
    assert($?.exitstatus == 255)
  
    system("ruby ../igc-kml.rb .")
    assert($?.exitstatus == 254)
    
    system("ruby ../igc-kml.rb -s data/25GXXXX2")
    assert($?.exitstatus == 253)
    
    system("ruby ../igc-kml.rb -s data/25GXXXX2.icg")
    assert($?.exitstatus == 253)
    
    system("ruby ../igc-kml.rb -s data/25GXXXX2_äöü-")
    assert($?.exitstatus == 253)
    
    system("ruby ../igc-kml.rb -s data/25GXXXX2.kml")
    assert($?.exitstatus == 253)
  
  end
  
  def test_file_names
    
    system("ruby ../igc-kml.rb data/25GXXXX1.igc")
    assert($?.exitstatus == 0)
    
    system("ruby ../igc-kml.rb data/25GXXXX1")
    assert($?.exitstatus == 0)
    
    system("ruby ../igc-kml.rb data/25GXXXX1_äöü-")
    assert($?.exitstatus == 0)
    
    system("ruby ../igc-kml.rb data/25GXXXX1.kml")
    assert($?.exitstatus == 0)
    
  end

end