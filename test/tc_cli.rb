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
    
    system("ruby ../igc-kml.rb data/25GXXXX1.igc")
    assert($?.exitstatus == 0)
    
    system("ruby ../igc-kml.rb data/25GXXXX1_corrupt.igc")
    assert($?.exitstatus == 253)
    
    # TODO: Test file name independence
  
  end

end