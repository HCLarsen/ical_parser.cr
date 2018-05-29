require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
    @eventc = <<-HEREDOC
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
  end

  def test_property_has_name
    property = Property.new("UID", BooleanParser.parser)
    assert_equal "UID", property.name
  end

  def test_property_gets_value
    property = Property.new("UID", TextParser.parser)
    uid = property.get(@eventc)
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
end
