require "minitest/autorun"

require "/../src/iCal"

class CalAddressTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @user = CalAddress.new(URI.parse("mailto:jsmith@example.com"))
  end

  def test_initializes_cal_address
    uri = URI.parse("mailto:jane_doe@example.com")
    user = CalAddress.new(uri)
    assert_equal "jane_doe@example.com", user.uri.opaque
  end

  def test_equality
    first_user = CalAddress.new(URI.parse("mailto:jdoe@example.com"))
    second_user = CalAddress.new(URI.parse("mailto:jdoe@example.com"))
    assert_equal first_user, second_user
  end

  def test_accepts_common_name
    @user.common_name = "John Smith"
    assert_equal "John Smith", @user.common_name
  end

  def test_accepts_member_cal_address
    member = CalAddress.new(URI.parse("mailto:ietf-calsch@example.org"))
    @user.member << member
    assert_equal "ietf-calsch@example.org", @user.member.first.uri.opaque
    assert_equal Array(CalAddress), @user.member.class
  end

  def test_accepts_sent_by_cal_address
    sent_by = CalAddress.new(URI.parse("mailto:sray@example.com"))
    @user.sent_by = sent_by
    assert_equal "sray@example.com", @user.sent_by.not_nil!.uri.opaque
    assert_equal CalAddress, @user.sent_by.class
  end

  def test_accepts_delegated_to_cal_address
    user = CalAddress.new(URI.parse("mailto:jdoe@example.com"))
    del_from = [CalAddress.new(URI.parse("mailto:jsmith@example.com"))]
    user.delegated_from = del_from
    assert_equal "jsmith@example.com", user.delegated_from.first.not_nil!.uri.opaque
    assert_equal Array(CalAddress), user.delegated_from.class
  end

  def test_accepts_delegated_from_cal_address
    del_to = [CalAddress.new(URI.parse("mailto:jdoe@example.com")), CalAddress.new(URI.parse("mailto:jqpublic@example.com"))]
    @user.delegated_to = del_to
    assert_equal "jdoe@example.com", @user.delegated_to.first.not_nil!.uri.opaque
    assert_equal Array(CalAddress), @user.delegated_to.class
  end

  def test_accepts_dir_uri
    dir = URI.parse("ldap://example.com:6666/o=ABC%20Industries,c=US???(cn=Jim%20Dolittle)")
    user = CalAddress.new(URI.parse("mailto:jimdo@example.com"))
    user.dir = dir
    assert_equal "example.com", user.dir.not_nil!.host
    assert_equal URI, user.dir.class
  end

  def test_rsvp_defaults_to_false
    assert_equal false, @user.rsvp
  end

  def test_rsvp_can_be_set_to_true
    @user.rsvp = true
    assert @user.rsvp
  end

  def test_role_defaults_to_req
    assert_equal CalAddress::Role::ReqParticipant, @user.role
  end

  def test_cutype_defaults_to_individual
    assert_equal CalAddress::CUType::Individual, @user.cutype
  end

  def test_partstat_defaults_to_needs_action
    assert_equal CalAddress::PartStat::NeedsAction, @user.part_stat
  end
end
