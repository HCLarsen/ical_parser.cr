require "minitest/autorun"

require "/../src/iCal"

class TextParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = TextParser.parser
  end

  def test_parses_text
    escaped = "I need to escape \\, \\; \\\\ but not \\n newline characters"
    text = "I need to escape , ; \\ but not \\n newline characters"
    assert_equal text, @parser.parse(escaped)
  end

  def test_parses_other_text
    escaped = "Networld+Interop Conference and Exhibit\\nAtlanta World Congress Center\\nAtlanta\\, Georgia"
    text = "Networld+Interop Conference and Exhibit\\nAtlanta World Congress Center\\nAtlanta, Georgia"
    assert_equal text, @parser.parse(escaped)
  end

  def test_generates_text
    text = "I need to escape , ; \\ but not \n newline characters"
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    assert_equal escaped, @parser.generate(text)
  end
end
