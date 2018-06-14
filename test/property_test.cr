require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
  end

  def test_property_has_name
    property = Property.new("UID", TextParser.parser)
    assert_equal "UID", property.name
  end

  def test_property_parses_value
    property = Property.new("DESCRIPTION", TextParser.parser)
    params = ""
    value = "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia"
    text = property.parse(params, value)
    assert_equal String, typeof(text)
    assert_equal "Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta, Georgia", text
  end

  def test_property_parses_value_with_params
    property = Property.new("ATTENDEE", CalAddressParser.parser)
    params = "RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP"
    value = "mailto:employee-A@example.com"
    address = property.parse(params, value)
    assert_equal "employee-A@example.com", address.uri.opaque
    assert address.rsvp
  end

  def test_property_gets_value
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    DTSTAMP:19960704T120000Z
    UID:uid1@example.com
    ORGANIZER:mailto:jsmith@example.com
    DTSTART:19960918T143000Z
    DTEND:19960920T220000Z
    STATUS:CONFIRMED
    CATEGORIES:CONFERENCE
    SUMMARY:Networld+Interop Conference
    DESCRIPTION:Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia
    END:VEVENT
    HEREDOC
    property = Property.new("UID", TextParser.parser)
    uid = property.get(eventc)
    assert_equal "uid1@example.com", uid
  end

  def test_raises_on_no_uid
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    DTSTAMP:19960704T120000Z
    ORGANIZER:mailto:jsmith@example.com
    DTSTART:19960918T143000Z
    DTEND:19960920T220000Z
    STATUS:CONFIRMED
    CATEGORIES:CONFERENCE
    SUMMARY:Networld+Interop Conference
    DESCRIPTION:Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia
    END:VEVENT
    HEREDOC

    property = Property.new("UID", TextParser.parser)
    error = assert_raises do
      uid = property.get(eventc)
    end
    assert_equal "Invalid Event: UID is REQUIRED", error.message
  end

  def test_raises_on_two_uids
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    DTSTAMP:19960704T120000Z
    UID:uid1@example.com
    UID:uid2@example.com
    ORGANIZER:mailto:jsmith@example.com
    DTSTART:19960918T143000Z
    DTEND:19960920T220000Z
    STATUS:CONFIRMED
    CATEGORIES:CONFERENCE
    SUMMARY:Networld+Interop Conference
    DESCRIPTION:Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia
    END:VEVENT
    HEREDOC

    property = Property.new("UID", TextParser.parser)
    error = assert_raises do
      uid = property.get(eventc)
    end
    assert_equal "Invalid Event: UID MUST NOT occur more than once", error.message
  end

  def test_match_is_case_insensitive
    eventc = <<-HEREDOC
    BEGIN:VEVENT
    DTSTAMP:19960704T120000Z
    UiD:uid1@example.com
    ORGANIZER:mailto:jsmith@example.com
    DTSTART:19960918T143000Z
    DTEND:19960920T220000Z
    STATUS:CONFIRMED
    CATEGORIES:CONFERENCE
    SUMMARY:Networld+Interop Conference
    DESCRIPTION:Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia
    END:VEVENT
    HEREDOC

    property = Property.new("UID", TextParser.parser)
    uid = property.get(eventc)
    assert_equal "uid1@example.com", uid
  end

  def test_parses_tz_params
    property = Property.new("UID", TextParser.parser)

    params = "TZID=America/New_York"
    hash = {"TZID" => "America/New_York"}
    assert_equal hash, property.parse_params(params)
  end

  def test_parses_multiple_params
    property = Property.new("UID", TextParser.parser)

    params = "ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;CN=Henry Cabot"
    hash = {"ROLE" => "REQ-PARTICIPANT", "PARTSTAT" => "TENTATIVE", "CN" => "Henry Cabot"}
    assert_equal hash, property.parse_params(params)
  end
end
