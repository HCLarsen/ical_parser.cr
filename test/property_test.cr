require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
  end

  def test_property_parses_value
    text_parser = TextParser.parser
    parser = ->text_parser.parse(String, Hash(String, String))
    property = Property(String).new(parser)
    params = ""
    value = "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia"
    text = property.parse(value, params)
    assert_equal "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta, Georgia", text

    found = Hash(String, PropertyType).new
    found["description"] = text
  end

  def test_property_parses_value_with_params
    address_parser = CalAddressParser.parser
    parser = ->address_parser.parse(String, Hash(String, String))
    property = Property(CalAddress).new(parser)
    params = ";RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP"
    value = "mailto:employee-A@example.com"
    address = property.parse(value, params)
    assert_equal CalAddress.new(URI.parse("mailto:employee-A@example.com")), address
    assert_equal CalAddress | Array(CalAddress) | Hash(String, CalAddress), typeof(address)
  end

  def test_single_category_returns_as_array
    text_parser = TextParser.parser
    parser = ->text_parser.parse(String, Hash(String, String))
    property = Property(String).new(parser, single_value: false, only_once: false)
    value = "MEETING"
    list = property.parse(value, "")
    assert_equal ["MEETING"], list
  end

  def test_parses_geo
    NamedTuple(lat: Float64, lon: Float64)
    float_parser = FloatParser.parser
    parser = ->float_parser.parse(String, Hash(String, String))
    property = Property(Float64).new(parser, parts: ["lat", "lon"])
    value = "37.386013;-122.082932"
    coords = property.parse(value, "")
    assert_equal coords.as(Hash(String, Float64))["lat"], 37.386013
    assert_equal coords.as(Hash(String, Float64))["lon"], -122.082932
  end

  def test_parses_tz_params
    text_parser = TextParser.parser
    parser = ->text_parser.parse(String, Hash(String, String))
    property = Property(String).new(parser)

    params = ";TZID=America/New_York"
    hash = {"TZID" => "America/New_York"}
    assert_equal hash, property.parse_params(params)
  end

  def test_parses_multiple_params
    text_parser = TextParser.parser
    parser = ->text_parser.parse(String, Hash(String, String))
    property = Property(String).new(parser)

    params = ";ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;CN=Henry Cabot"
    hash = {"ROLE" => "REQ-PARTICIPANT", "PARTSTAT" => "TENTATIVE", "CN" => "Henry Cabot"}
    assert_equal hash, property.parse_params(params)
  end

  def test_property_parses_params_with_array_value
    address_parser = CalAddressParser.parser
    parser = ->address_parser.parse(String, Hash(String, String))
    property = Property(CalAddress).new(parser)
    params = %(;DELEGATED-TO="mailto:jdoe@example.com","mailto:jqpublic@example.com")
    parsed_params = property.parse_params(params)
    assert_equal %("mailto:jdoe@example.com","mailto:jqpublic@example.com"), parsed_params["DELEGATED-TO"]
  end
end
