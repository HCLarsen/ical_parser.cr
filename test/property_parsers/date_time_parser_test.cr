require "minitest/autorun"

require "/../src/ical_parser/property_parsers/date_time_parser"
require "/../src/ical_parser/common"
# require "/../src/iCal"

class DateTimeParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, String)

  def initialize(arg)
    super(arg)
    @parser = @@date_time_parser
  end

  def test_parses_floating_date_time
    string = "19980118T230000"
    dateTime = @parser.call(string)
    assert_equal string, dateTime
  end

  def test_parses_utc_date_time
    string = "19980119T070000Z"
    dateTime = @parser.call(string)
    assert_equal string, dateTime
  end

  def test_parses_date_time_with_time_zone
    string = "19970714T133000"
    dateTime = @parser.call(string)
    assert_equal string, dateTime
  end

  def test_raises_for_invalid_time_format
    string = "19980119T230000-0800"
    error = assert_raises do
      @parser.call(string)
    end
    assert_equal "Invalid Date-Time format", error.message
  end

  def test_raises_for_invalid_date_time_format
    string = "19980119230000"
    error = assert_raises do
      @parser.call(string)
    end
    assert_equal "Invalid Date-Time format", error.message
  end

  def test_raises_for_date_time_without_time
    string = "19980118T"
    error = assert_raises do
      @parser.call(string)
    end
    assert_equal "Invalid Date-Time format", error.message
  end
end
