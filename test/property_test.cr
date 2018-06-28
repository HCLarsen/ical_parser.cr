require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
  end

  def test_property_has_name
    property = Property.new("UID", TextParser.parser)
    assert_equal "UID", property.name
  end

  def test_property_parses_value
    property = Property.new("DESCRIPTION", TextParser.parser)
    params = ""
    value = "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia"
    text = property.parse(params, value)
    assert_equal String, typeof(text)
    assert_equal "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta, Georgia", text
  end

  def test_property_parses_value_with_params
    property = Property.new("ATTENDEE", CalAddressParser.parser)
    params = "RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP"
    value = "mailto:employee-A@example.com"
    address = property.parse(params, value)
    assert_equal "employee-A@example.com", address.uri.opaque
  end

  def test_parses_tz_params
    property = Property.new("UID", TextParser.parser)

    params = "TZID=America/New_York"
    hash = {"TZID" => "America/New_York"}
    assert_equal hash, property.parse_params(params)
  end

  def test_parses_multiple_params
    property = Property.new("UID", TextParser.parser)

    params = "ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;CN=Henry Cabot"
    hash = {"ROLE" => "REQ-PARTICIPANT", "PARTSTAT" => "TENTATIVE", "CN" => "Henry Cabot"}
    assert_equal hash, property.parse_params(params)
  end

  def test_property_parses_params_with_array_value
    property = Property.new("ATTENDEE", CalAddressParser.parser)
    params = %(DELEGATED-TO="mailto:jdoe@example.com","mailto:jqpublic@example.com")
    parsed_params = property.parse_params(params)
    assert_equal %("mailto:jdoe@example.com","mailto:jqpublic@example.com"), parsed_params["DELEGATED-TO"]
  end
end
