require "minitest/autorun"

require "/../src/ical_parser/property_parsers/text_parser"
require "/../src/ical_parser/common"

class TextParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)
  @generator : Proc(String, String)

  def initialize(arg)
    super(arg)
    @parser = @@text_parser
    @generator = @@text_generator
    @params = Hash(String, String).new
  end

  def test_parses_text
    string = "I need to escape \\, \\; \\\\ but not \\n newline characters"
    expected = "I need to escape , ; \\\\ but not \\\\n newline characters"
    result = @parser.call(string, @params)
    assert_equal %("#{expected}"), result
  end

  def test_parses_other_text
    string = "Networld+Interop Conference and Exhibit\\nAtlanta World Congress Center\\nAtlanta\\, Georgia"
    expected = "Networld+Interop Conference and Exhibit\\\\nAtlanta World Congress Center\\\\nAtlanta, Georgia"
    result = @parser.call(string, @params)
    assert_equal %("#{expected}"), result
  end

  def test_generates_text
    text = "I need to escape , ; \\ but not \n newline characters"
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    assert_equal escaped, @generator.call(text)
  end
end
