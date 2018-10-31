require "minitest/autorun"

require "/../src/iCal"

class DateParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), Time)

  def initialize(arg)
    super(arg)
    @parser = @@date_parser
    @params = Hash(String, String).new
  end

  def test_parses_date
    string = "19970714"
    date = @parser.call(string, @params)
    assert_equal Time.new(1997, 7, 14), date
    assert_equal Time::Location.local, date.location
  end

  def test_raises_for_invalid_date_format
    string = "970714"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Date format", error.message
  end

  def test_raises_for_invalid_date
    string = "19970740"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Date", error.message
  end
end
