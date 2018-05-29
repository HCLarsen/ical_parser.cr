require "minitest/autorun"

require "/../src/iCal"

class DateParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = DateParser.parser
  end

  def test_parses_date
    date = "19970714"
    assert_equal Time.new(1997,7,14), @parser.parse(date)
  end
end
