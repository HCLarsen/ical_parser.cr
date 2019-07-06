require "minitest/autorun"

require "/../src/ical_parser/property_parsers/cal_address_parser"
require "/../src/ical_parser/common"
require "/../src/ical_parser/enums"
# require "/../src/iCal"

class CalAddressParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, String)

  def initialize(arg)
    super(arg)
    @parser = @@caladdress_parser
  end

  def test_parses_simple_address
    string = "mailto:jsmith@example.com"
    address = @parser.call(string)
    assert_equal string, address
  end
end
