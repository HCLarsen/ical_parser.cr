require "minitest/autorun"

require "/../src/iCal"

class TextParserTest < Minitest::Test
  def test_parses_date
    date = "19970714"
    assert_equal Time.new(1997,7,14), ICal::DateParser.parse(date)
  end
end
