require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def test_property_has_name
    property = Property.new("UID")
    assert_equal "UID", property.name
  end
end
