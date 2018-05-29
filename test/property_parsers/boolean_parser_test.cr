require "minitest/autorun"

require "/../src/iCal"

class BooleanParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = BooleanParser.parser
  end

  def test_parser_is_singleton
    parser1 = BooleanParser.parser
    parser2 = BooleanParser.parser
    assert_equal BooleanParser, parser1.class
    assert parser1.same?(parser2)
    error = assert_raises do
      parser1.dup
    end
    assert_equal "Can't duplicate instance of singleton IcalParser::BooleanParser", error.message
  end

  def test_returns_true_for_true_value
    string = "TRUE"
    assert @parser.parse(string)
  end

  def test_returns_false_for_false_value
    string = "FALSE"
    refute @parser.parse(string)
  end

  def test_raises_for_invalid_value
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.parse(string)
    end
    assert_equal "Invalid Boolean value", error.message
  end
end
