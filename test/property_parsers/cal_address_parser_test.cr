require "minitest/autorun"

require "/../src/iCal"
require "/../src/ical_parser/cal_address"

class CalAddressParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = CalAddressParser.parser
  end

  def test_parses_simple_address
    params = { "CN" => "John Smith" }
    string = "mailto:jsmith@example.com"
    uri = URI.parse(string)
    address = @parser.parse(string, params)
    assert_equal uri, address.uri
    assert_equal "John Smith", address.common_name
  end

  def test_parses_sent_by
    params = { "SENT-BY" => "mailto:jane_doe@example.com" }
    string = "mailto:jsmith@example.com"
    uri = URI.parse(string)
    address = @parser.parse(string, params)
    assert_equal "mailto:jane_doe@example.com", address.sent_by
  end
end
