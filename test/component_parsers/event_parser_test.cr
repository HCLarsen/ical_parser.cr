require "minitest/autorun"

require "/../src/iCal"

class EventParserTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
    @parser = EventParser.parser
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
    eventc = <<-HEREDOC
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

    event = @parser.parse(eventc)
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
    assert_equal "TRANSPARENT", event.transp
    refute event.opaque?
  end

  def test_parses_with_duration
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    SUMMARY:Lunchtime meeting
    DTSTAMP:20160418T135200
    UID:ff808181-1fd7389e-011f-d7389ef9-00000003
    DTSTART;TZID=America/New_York:20160420T120000
    DURATION:PT1H
    END:VEVENT
    HEREDOC

    event = @parser.parse(eventc)
    assert_equal Time::Span.new(0, 1, 0, 0), event.duration
    assert_equal Time.new(2016, 4, 20, 13, 0, 0, location: Time::Location.load("America/New_York")), event.dtend
  end

  def test_parses_multiple_category_lines
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123403@example.com
    DTSTAMP:19970901T130000Z
    DTSTART;VALUE=DATE:19971102
    SUMMARY:Our Blissful Anniversary
    TRANSP:TRANSPARENT
    CLASS:CONFIDENTIAL
    CATEGORIES:ANNIVERSARY,PERSONAL
    CATEGORIES:SPECIAL OCCASION
    RRULE:FREQ=YEARLY
    END:VEVENT
    HEREDOC

    event = @parser.parse(eventc)
    assert_equal 3, event.categories.size
    assert_equal RecurrenceRule::Freq::Yearly, event.recurrence.not_nil!.frequency
  end

  def test_parses_geo_property
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:20070423T123432Z-541111@example.com
    DTSTAMP:20070423T123432Z
    DTSTART;VALUE=DATE:20070628
    DTEND;VALUE=DATE:20070709
    SUMMARY:Festival International de Jazz de Montreal
    GEO:45.5;-73.567
    TRANSP:TRANSPARENT
    END:VEVENT
    HEREDOC

    event = @parser.parse(eventc)
    assert_equal 45.5, event.geo.not_nil!["lat"]
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
    assert_equal "Invalid Event: Invalid content line: CLASS", error.message
  end

  def test_raises_if_multiple_uids
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    UID:20070423T123432Z-541111@example.com
    DTSTART:19970903T163000Z
    DTEND:19970903T190000Z
    DTSTAMP:19970901T130000Z
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: UID MUST NOT occur more than once", error.message
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
    assert_equal "Invalid Event: DTSTART and DTEND must be the same value type", error.message
  end

  def test_raises_for_all_day_event_with_hour_duration
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    UID:20070423T123432Z-541111@example.com
    DTSTAMP:20070423T123432Z
    DTSTART;VALUE=DATE:20070628
    DURATION:PT1H
    SUMMARY:Festival International de Jazz de Montreal
    TRANSP:TRANSPARENT
    END:VEVENT
    HEREDOC

    error = assert_raises do
      event = @parser.parse(eventc)
    end
    assert_equal "Invalid Event: DURATION MUST be day or week duration only", error.message
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
