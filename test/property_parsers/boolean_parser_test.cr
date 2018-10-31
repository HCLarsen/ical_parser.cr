require "minitest/autorun"

require "/../src/iCal"

class BooleanParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), Bool)

  def initialize(arg)
    super(arg)
    @parser = @@boolean_parser
    @params = Hash(String, String).new
  end

  def test_returns_true_for_true_value
    string = "TRUE"
    assert @parser.call(string, @params)
  end

  def test_returns_false_for_false_value
    string = "FALSE"
    refute @parser.call(string, @params)
  end

  def test_raises_for_invalid_value
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Boolean value", error.message
  end
end
