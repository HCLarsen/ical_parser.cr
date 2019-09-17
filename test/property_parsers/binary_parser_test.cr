require "minitest/autorun"

require "/../src/ical_parser/property_parsers/binary_parser"

class BinaryParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@binary_parser
    @params = Hash(String, String).new
  end

  def test_parses_base_64_data
    string = "This is my binary data"
    data = Base64.encode(string)
    assert_equal string, @parser.call(data, @params)
  end
end
