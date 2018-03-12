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

  def test_should_parse_one_hour_duration
    text = "PT1H"
    assert_equal Time::Span.new(1, 0, 0), ICal::Parser.duration(text)
  end

  def test_should_parse_multi_parameter_duration
    text = "P15DT5H0M20S"
    assert_equal Time::Span.new(15, 5, 0, 20), ICal::Parser.duration(text)
  end

  def test_should_parse_one_week_duration
    text = "P7W"
    assert_equal Time::Span.new(49, 0, 0, 0), ICal::Parser.duration(text)
  end

  def test_should_identify_floating_DateTime
    dateTime = ICal::Parser.from_iCalDT("19980119T070000")
    assert_equal Time.new(1998, 1, 19, 7, 0, 0, nanosecond: 0, kind: Time::Kind::Local), dateTime
    assert dateTime.local?
  end

  def test_should_identify_UTC_DateTime
    dateTime = ICal::Parser.from_iCalDT("19980119T070000Z")
    assert_equal Time.utc(1998, 1, 19, 7, 0, 0), dateTime
    assert dateTime.utc?
  end

  def test_should_identify_DateTime_with_TimeZone
    dateTime = ICal::Parser.from_iCalDT("TZID=America/New_York:19980119T020000")
    assert_equal Time.new(1998, 1, 19, 2, 0, 0, nanosecond: 0, kind: Time::Kind::Local), dateTime
    assert dateTime.local?
  end
end
