require "minitest/autorun"

require "/../src/iCal"

class EventTest < Minitest::Test
  include IcalParser

  def test_initializes_event_without_end_time
    uid = "19970901T130000Z-123403@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 11, 2)
    event = IcalParser::Event.new(uid, dtstamp, dtstart)
    assert_equal uid, event.uid
    assert_equal dtstamp, event.dtstamp
  end

  def test_initializes_event_with_end_time
    uid = "19970901T130000Z-123401@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 9, 3, 16, 30, 0)
    dtend = Time.utc(1997, 9, 3, 19, 0, 0)
    event = IcalParser::Event.new(uid, dtstamp, dtstart, dtend)
    assert_equal uid, event.uid
    assert_equal dtstart, event.dtstart
    assert_equal dtend, event.dtend
  end

  def test_initializes_event_with_duration
    uid = "19970901T130000Z-123401@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 9, 3, 16, 30, 0)
    duration = Time::Span.new(0, 1, 0, 0)
    dtend = Time.utc(1997, 9, 3, 17, 30, 0)
    event = IcalParser::Event.new(uid, dtstamp, dtstart, duration)
    assert_equal uid, event.uid
    assert_equal dtend, event.dtend
  end

  def test_initializes_event_from_hash
    props = {
      "uid"     => "19970901T130000Z-123401@example.com",
      "dtstamp" => Time.utc(1997, 9, 1, 13, 0, 0),
      "dtstart" => Time.utc(1997, 9, 3, 16, 30, 0),
      "dtend"   => Time.utc(1997, 9, 3, 19, 0, 0),
    } of String => PropertyType
    event = IcalParser::Event.new(props)
    assert_equal props["uid"], event.uid
    assert_equal props["dtstart"], event.dtstart
    assert_equal props["dtend"], event.dtend
  end

  def test_raises_error_if_end_time_earlier_than_start_time
    uid = "19970901T130000Z-123401@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 9, 3, 16, 30, 0)
    dtend = Time.utc(1997, 9, 3, 11, 0, 0)
    error = assert_raises do
      event = IcalParser::Event.new(uid, dtstamp, dtstart, dtend)
    end
    assert_equal "Invalid Event: End time cannot precede start time", error.message
  end

  def test_raises_error_on_negative_duration
    uid = "19970901T130000Z-123401@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 9, 3, 16, 30, 0)
    duration = Time::Span.new(0, -1, 0, 0)
    error = assert_raises do
      event = IcalParser::Event.new(uid, dtstamp, dtstart, duration)
    end
    assert_equal "Invalid Event: Duration must be positive", error.message
  end

  def test_raises_if_setting_start_time_later_than_end_time
    uid = "19970901T130000Z-123401@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 9, 3, 16, 30, 0)
    dtend = Time.utc(1997, 9, 3, 19, 0, 0)
    event = IcalParser::Event.new(uid, dtstamp, dtstart, dtend)
    error = assert_raises do
      event.dtstart = Time.utc(1997, 9, 3, 19, 30, 0)
    end
    assert_equal "Invalid Event: End time cannot precede start time", error.message
  end

  def test_raises_if_setting_end_time_earlier_than_start_time
    uid = "19970901T130000Z-123401@example.com"
    dtstamp = Time.utc(1997, 9, 1, 13, 0, 0)
    dtstart = Time.utc(1997, 9, 3, 16, 30, 0)
    dtend = Time.utc(1997, 9, 3, 19, 0, 0)
    event = IcalParser::Event.new(uid, dtstamp, dtstart, dtend)
    error = assert_raises do
      event.dtend = Time.utc(1997, 9, 3, 16, 0, 0)
    end
    assert_equal "Invalid Event: End time cannot precede start time", error.message
  end
end
