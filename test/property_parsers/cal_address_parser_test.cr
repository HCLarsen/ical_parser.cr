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
    string = "mailto:jsmith@example.com"
    uri = URI.parse(string)
    address = @parser.parse(string)
    assert_equal uri, address.uri
  end

#  def test_parses_sent_by
#    params = { "SENT-BY" => "mailto:jane_doe@example.com" }
#    string = "mailto:jsmith@example.com"
#    uri = URI.parse(string)
#    address = @parser.parse(string, params)
#    assert_equal "mailto:jane_doe@example.com", address.sent_by
#  end
end
