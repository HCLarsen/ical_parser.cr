require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
  end

  def test_property_parses_value
    prop = Property(String).new(@@text_parser)
    value = "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia"
    params = {} of String => String
    json = %({"params":#{params},"value":#{value.to_json}})
    result = prop.parse(value, "")
    assert_equal json, result
  end

  def test_property_parses_value_with_params
    prop = Property(String).new(@@caladdress_parser)
    params = ";RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP"
    value = "mailto:employee-A@example.com"
    json = %({"params":{"RSVP":"TRUE","ROLE":"REQ-PARTICIPANT","CUTYPE":"GROUP"},"value":"#{value}"})
    result = prop.parse(value, params)
    assert_equal json, result
  end

  def test_single_category_returns_as_array
    prop = Property(String).new(@@text_parser, single_value: false, only_once: false)
    value = "MEETING"
    params = {} of String => String
    json = %({"params":#{params},"value":#{[value]}})
    result = prop.parse(value, "")
    assert_equal json, result
  end

  def test_parses_geo
    NamedTuple(lat: Float64, lon: Float64)
    prop = Property(Float64).new(@@float_parser, parts: ["lat", "lon"])
    value = "37.386013;-122.082932"
    params = {} of String => String
    expected = %({"params":#{params},"value":{"lat":#{37.386013},"lon":#{-122.082932}}})

    result = prop.parse(value, "")
    assert_equal expected, result
  end

  def test_property_parses_params_with_array_value
    prop = Property(CalAddress).new(@@caladdress_parser)
    params = %(;DELEGATED-TO="mailto:jdoe@example.com","mailto:jqpublic@example.com")
    parsed_params = prop.parse_params(params)
    assert_equal %({"DELEGATED-TO":["mailto:jdoe@example.com","mailto:jqpublic@example.com"]}), parsed_params
  end

  def test_multiple_return_types
    prop = Property(String).new(@@date_time_parser, alt_values: ["DATE", "PERIOD"], single_value: false, only_once: false)

    value = "19970714T083000"
    expected = %({"params":{"TZID":"America/New_York"},"value":#{[value]}})
    date_time = prop.parse(value, ";TZID=America/New_York")
    assert_equal expected, date_time
  end

  def test_parses_array_of_dates
    prop = Property(String).new(@@date_time_parser, alt_values: ["DATE", "PERIOD"], single_value: false, only_once: false)

    date_value = "19970101,19970120,19970217,19970421,19970526,19970704,19970901,19971014,19971128,19971129,19971225"
    expected = %({"params":{"VALUE":"DATE"},"value":["19970101","19970120","19970217","19970421","19970526","19970704","19970901","19971014","19971128","19971129","19971225"]})
    result = prop.parse(date_value, "VALUE=DATE")
    assert_equal expected, result
  end

  def test_raise_for_invalid_value_type
    prop = Property(String).new(@@date_time_parser, alt_values: ["DATE", "PERIOD"], single_value: false, only_once: false)
    date_value = "19970101,19970120,19970217,19970421,19970526,19970704,19970901,19971014,19971128,19971129,19971225"
    error = assert_raises do
      dates = prop.parse(date_value, "VALUE=TEXT")
    end
    assert_equal "Invalid value type for this property", error.message
  end
end
