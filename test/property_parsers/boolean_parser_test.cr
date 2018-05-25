require "minitest/autorun"

require "/../src/iCal"

class BooleanParserTest < Minitest::Test
  def test_returns_true_for_true_value
    string = "TRUE"
    assert ICal::BooleanParser.parse(string)
  end

  def test_returns_false_for_false_value
    string = "FALSE"
    refute ICal::BooleanParser.parse(string)
  end

  def test_raises_for_invalid_value
    string = "SOMETHING ELSE"
    error = assert_raises do
      ICal::BooleanParser.parse(string)
    end
    assert_equal "Invalid Boolean value", error.message
  end
end
