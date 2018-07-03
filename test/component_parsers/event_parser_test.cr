require "minitest/autorun"

require "/../src/iCal"

class EventParserTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
    @parser = EventParser.parser
    @eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    DTSTAMP:19970901T130000Z
    DTSTART:19970903T163000Z
    DTEND:19970903T190000Z
    SUMMARY:Annual Employee Review
    CLASS:PRIVATE
    CATEGORIES:BUSINESS,HUMAN RESOURCES
    END:VEVENT
    HEREDOC
  end

  def test_returns_parser
    assert_equal EventParser, @parser.class
  end

  def test_parser_is_singleton
    parser1 = EventParser.parser
    parser2 = EventParser.parser
    assert parser1.same?(parser2)
    error = assert_raises do
      parser1.dup
    end
    assert_equal "Can't duplicate instance of singleton IcalParser::EventParser", error.message
  end

  def test_parses_minimal_event
    event = @parser.parse(@eventc)
    assert_equal "19970901T130000Z-123401@example.com", event.uid
    assert_equal Time.utc(1997, 9, 1, 13, 0, 0), event.dtstamp
    assert_equal Time.utc(1997, 9, 3, 16, 30, 0), event.dtstart
    assert_equal Time.utc(1997, 9, 3, 19, 0, 0), event.dtend
    assert_equal "Annual Employee Review", event.summary
    assert_equal "PRIVATE", event.classification
    assert_equal ["BUSINESS", "HUMAN RESOURCES"], event.categories
    assert event.opaque?
  end

  def test_parses_anniversary_event
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123403@example.com
    DTSTAMP:19970901T130000Z
    DTSTART;VALUE=DATE:19971102
    SUMMARY:Our Blissful Anniversary
    TRANSP:TRANSPARENT
    CLASS:CONFIDENTIAL
    CATEGORIES:ANNIVERSARY,PERSONAL,SPECIAL OCCASION
    RRULE:FREQ=YEARLY
    END:VEVENT
    HEREDOC
    event = @parser.parse(eventc)
    assert_equal Time.new(1997, 11, 2), event.dtstart
    assert event.all_day?
    refute event.opaque?
  end

  def test_raises_for_invalid_line
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    DTSTAMP:19970901T130000Z
    DTSTART:19970903T163000Z
    DTEND:19970903T190000Z
    CLASS
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: No value on line CLASS", error.message
  end

  def test_raises_if_start_missing
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:20070423T123432Z-541111@example.com
    DTSTAMP:20070423T123432Z
    SUMMARY:Festival International de Jazz de Montreal
    TRANSP:TRANSPARENT
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: DTSTART is REQUIRED", error.message
  end

  def test_raises_when_start_is_date_and_end_is_date_time
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:20070423T123432Z-541111@example.com
    DTSTAMP:20070423T123432Z
    DTSTART;VALUE=DATE:20070628
    DTEND:20070709T193000
    SUMMARY:Festival International de Jazz de Montreal
    TRANSP:TRANSPARENT
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: DTSTART is DATE but DTEND is DATE-TIME", error.message
  end

  def test_raises_for_earlier_end_than_start_date
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    DTSTAMP:19970901T130000Z
    DTSTART:19970903T163000Z
    DTEND:19970903T160000Z
    SUMMARY:Annual Employee Review
    CLASS:PRIVATE
    CATEGORIES:BUSINESS,HUMAN RESOURCES
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: DTEND MUST BE later than DTSTART", error.message
  end

  def test_raises_if_end_and_duration_are_present
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    DTSTAMP:19970901T130000Z
    DTSTART:19970903T163000Z
    DTEND:19970903T190000Z
    DURATION:PT1H
    SUMMARY:Annual Employee Review
    CLASS:PRIVATE
    CATEGORIES:BUSINESS,HUMAN RESOURCES
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: DTEND and DURATION MUST NOT appear in the same event", error.message
  end

  def test_raises_for_invalid_transp_value
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:20070423T123432Z-541111@example.com
    DTSTAMP:20070423T123432Z
    DTSTART;VALUE=DATE:20070628
    DTEND;VALUE=DATE:20070709
    SUMMARY:Festival International de Jazz de Montreal
    TRANSP:INVALID VALUE
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: TRANSP must be either OPAQUE or TRANSPARENT", error.message
  end
end
