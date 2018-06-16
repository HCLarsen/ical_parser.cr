require "minitest/autorun"

require "/../src/iCal"

class DateParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = DateParser.parser
  end

  def test_parses_date
    date = @parser.parse("19970714")
    assert_equal Time.new(1997,7,14), date
    assert_equal Time::Location.local, date.location
  end

  def test_raises_for_invalid_date_format
    error = assert_raises do
      @parser.parse("970714")
    end
    assert_equal "Invalid Date format", error.message
  end

  def test_raises_for_invalid_date
    error = assert_raises do
      @parser.parse("19970740")
    end
    assert_equal "Invalid Date", error.message
  end
end
