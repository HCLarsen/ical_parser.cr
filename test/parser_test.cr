require "minitest/autorun"

require "/../src/ICal/parser"

class ParserTest < Minitest::Test
  def test_should_escape_text_properly
    text = "I need to escape , ; \\ but not \n newline characters"
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    assert_equal escaped, ICal::Parser.rfc5545_text_escape(text)
  end

  def test_should_unescape_text_properly
    text = "I need to escape , ; \\ but not \n newline characters"
    escaped = "I need to escape \\, \\; \\\\ but not \n newline characters"
    assert_equal text, ICal::Parser.rfc5545_text_unescape(escaped)
  end

  def test_should_identify_UTC_DateTime
    dateTime = ICal::Parser.from_iCalDT("19980119T070000Z")
    assert_equal Time.utc(1998, 1, 19, 7, 0, 0), dateTime
    assert dateTime.utc?
  end

  def test_should_identify_floating_DateTime
    dateTime = ICal::Parser.from_iCalDT("19980119T070000")
    assert_equal Time.new(1998, 1, 19, 7, 0, 0, nanosecond: 0, kind: Time::Kind::Local), dateTime
    assert dateTime.local?
  end
end
