require "test/unit"
require "../igc-kml"

class TestLocation < Test::Unit::TestCase
  
  def test_constructor
    assert_raise(ArgumentError) {Converter.new}
  end
  
end