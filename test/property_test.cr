require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
  end

  def test_initializes
    contact_prop = Property.new(name: "contact", key: "contacts", only_once: false)
    assert_equal "contact", contact_prop.name
    assert_equal "contacts", contact_prop.key
    refute contact_prop.list
  end

  def test_returns_default_key
    prop = Property.new(name: "description")
    assert_equal "description", prop.key
  end

  def test_derives_list_from_component_property
    category_prop = Property.new("categories", only_once: false)
    assert category_prop.list
  end

  def test_property_parses_value
    prop = Property.new(name: "description")
    value = "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia"
    result = prop.parse(value, "").as String
    expected = %("Networld+Interop Conference and Exhibit\\nAtlanta World Congress Center\\nAtlanta, Georgia")
    assert_equal expected, result
  end

  def test_property_parses_value_with_params
    prop = Property.new("contact")
    params = ";RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP"
    value = "mailto:employee-A@example.com"
    result = prop.parse(value, params)
    expected = %({"uri":"mailto:employee-A@example.com","rsvp":true,"role":"REQ-PARTICIPANT","cutype":"GROUP"})
    assert_equal expected, result
  end

  def test_single_category_returns_as_array
    prop = Property.new("categories", only_once: false)
    value = "MEETING"
    list = prop.parse(value, "")
    assert_equal %(["MEETING"]), list
  end

  def test_parses_geo
    prop = Property.new("geo", parts: ["lat", "lon"])
    value = "37.386013;-122.082932"
    result = prop.parse(value, "")
    expected = %({"lat":37.386013,"lon":-122.082932})
    assert_equal expected, result
  end

  def test_parses_multiple_params
    prop = Property.new("contact")
    params = ";ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;CN=Henry Cabot"
    hash = {"ROLE" => "REQ-PARTICIPANT", "PARTSTAT" => "TENTATIVE", "CN" => "Henry Cabot"}
    assert_equal hash, prop.parse_params(params)
  end

  def test_property_parses_params_with_array_value
    prop = Property.new("attendee")
    params = %(;DELEGATED-TO="mailto:jdoe@example.com","mailto:jqpublic@example.com")
    parsed_params = prop.parse_params(params)
    assert_equal %("mailto:jdoe@example.com","mailto:jqpublic@example.com"), parsed_params["DELEGATED-TO"]
  end

  def test_parses_request_status
    prop = Property.new("request_status", only_once: false)
    value = "4.1;Event conflict.  Date-time is busy."
    result = prop.parse(value, "")
    expected = %(["4.1;Event conflict.  Date-time is busy."])
    assert_equal expected, result
  end

  def test_parse_alternate_type
    prop = Property.new("exdate", only_once: false)
    date_value = "19970101,19970120,19970217,19970421,19970526,19970704,19970901,19971014,19971128,19971129,19971225"
    dates = prop.parse(date_value, "VALUE=DATE")
    assert_equal %(["1997-01-01","1997-01-20","1997-02-17","1997-04-21","1997-05-26","1997-07-04","1997-09-01","1997-10-14","1997-11-28","1997-11-29","1997-12-25"]), dates
  end

  def test_multiple_return_types
    prop = Property.new("exdate", only_once: false)
    dt_value = "19970714T083000"
    date_time = prop.parse(dt_value, ";TZID=America/New_York")
    expected = %(["1997-07-14T08:30:00-04:00"])
    assert_equal expected, date_time
  end

  def test_raise_for_invalid_value_type
    prop = Property.new("exdate", only_once: false)
    date_value = "19970101,19970120,19970217,19970421,19970526,19970704,19970901,19971014,19971128,19971129,19971225"
    error = assert_raises do
      dates = prop.parse(date_value, "VALUE=TEXT")
    end
    assert_equal "Invalid value type for this property", error.message
  end

  # def test_raises_for_no_value_types
  #   error = assert_raises do
  #     Property.new("")
  #   end
  #   assert_equal "Property Error: Property must have at least ONE value type", error.message
  # end
end
