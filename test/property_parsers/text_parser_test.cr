require "minitest/autorun"

require "/../src/iCal"

class TextParserTest < Minitest::Test
  include IcalParser

  def test_parses_text
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    text = "I need to escape , ; \\ but not \n newline characters"
    assert_equal text, TextParser.parse(escaped)
  end

  def test_generates_text
    text = "I need to escape , ; \\ but not \n newline characters"
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    assert_equal escaped, TextParser.generate(text)
  end
end
