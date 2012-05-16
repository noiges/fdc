require "test/unit"
require "../igc-kml"

class TestConverter < Test::Unit::TestCase
  
  def test_constructor
    assert_raise(ArgumentError) {Converter.new}
  end
  
  def test_raised_exceptions
    
  end
  
end