require 'test/unit'
require 'igc-kml'

class IGCConverterTest < Test::Unit::TestCase
  
  def test_initialization
    assert_raise LoadError do 
      Converter.new "data/foo.kml"
    end
    assert_raise IOError do 
      Converter.new "data"
    end
    assert_raise IOError do 
      Converter.new "data/foo.igc"
    end
  end
  
  def test_file_input
    
  end
  
  def test_file_output
    
  end
  
end