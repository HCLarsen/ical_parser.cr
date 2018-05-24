require "minitest/autorun"

require "/../src/iCal"

class TextParserTest < Minitest::Test
  def test_parses_text
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    text = "I need to escape , ; \\ but not \n newline characters"
    assert_equal text, ICal::TextParser.parse(escaped)
  end

  def test_generates_text
    text = "I need to escape , ; \\ but not \n newline characters"
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    assert_equal escaped, ICal::TextParser.generate(text)
  end
end
