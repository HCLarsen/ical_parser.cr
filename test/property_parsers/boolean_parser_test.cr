require "minitest/autorun"

require "/../src/iCal"

class BooleanParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Bool)

  def initialize(arg)
    super(arg)
    @parser = @@boolean_parser
  end

  def test_returns_true_for_true_value
    string = "TRUE"
    assert @parser.call(string)
  end

  def test_returns_false_for_false_value
    string = "FALSE"
    refute @parser.call(string)
  end

  def test_raises_for_invalid_value
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.call(string)
    end
    assert_equal "Invalid Boolean value", error.message
  end
end
