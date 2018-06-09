require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def test_initializes_with_member
    uri = URI.parse("mailto:joecool@example.com")
    params = { "member" =>  "mailto:DEV-GROUP@example.com" }
    user = CalAddress.new(uri, params)
    assert_equal uri, user.uri
    assert_equal "mailto:dev-group@example.com", user.member
  end

  def test_initializes_with_delegated_from
    uri = URI.parse("mailto:joecool@example.com")
    params = { "DELEGATED-FROM" =>  "mailto:immud@example.com" }
    user = CalAddress.new(uri, params)
    assert_equal "mailto:immud@example.com", user.delegated_from
  end

  def test_initializes_with_multiple_params
    uri = URI.parse("mailto:iamboss@example.com")
    params = { "ROLE" => "NON-PARTICIPANT", "PARTSTAT" => "DELEGATED", "DELEGATED-TO" => "mailto:hcabot@example.com", "CN" => "The Big Cheese" }
    user = CalAddress.new(uri, params)
    assert_equal "non-participant", user.role
    assert_equal "The Big Cheese", user.common_name
  end

  def test_sets_rsvp
    uri = URI.parse("mailto:jsmith@example.com")
    params = { "RSVP" => "TRUE" }
    user = CalAddress.new(uri, params)
    assert_equal uri, user.uri
    assert user.rsvp
  end
end
