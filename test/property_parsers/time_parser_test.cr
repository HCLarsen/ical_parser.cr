require "minitest/autorun"

require "/../src/iCal"

class TimeParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = TimeParser.parser
  end

  def test_parses_time
    time = "230000"
    assert_equal Time.new(1,1,1,23,0,0), @parser.parse(time)
  end
end
