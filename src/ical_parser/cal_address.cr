#IANA, non-standard, language, calendar user type, group or list membership, participation role, participation status, RSVP expectation, delegatee, delegator, sent by, common name, or directory entry

module IcalParser
  # Representation of the [Cal-Address](https://tools.ietf.org/html/rfc5545#section-3.3.3) value type
  #
  # uri = URI.parse("mailto:iamboss@example.com")
  # params = { "ROLE" => "NON-PARTICIPANT", "PARTSTAT" => "DELEGATED", "CN" => "The Big Cheese" }
  # user = CalAddress.new(uri, params)
  # user.uri.opaque #=> iamboss@example.com
  # user.common_name  #=> "The Big Cheese"
  # user.role #=> non-participant
  class CalAddress
    enum Role
      Chair
      ReqParticipant
      OptParticipant
      NonParticipant
    end

    enum CUType
      Individual
      Group
      Resource
      Room
      Unknown
    end

    enum PartStat
      NeedsAction
      Accepted
      Declined
      Tentative
      Delegated
    end

    property uri : URI

    property cutype = CUType::Individual
    property member : CalAddress?
    property role = Role::ReqParticipant
    property part_stat = PartStat::NeedsAction
    property rsvp = false
    property delegated_to = [] of CalAddress
    property delegated_from = [] of CalAddress
    property language : String?
    property sent_by : CalAddress?
    property common_name : String?
    property dir : URI?

    # Creates a new CalAddress object with the specified URI.
    #
    # uri = URI.parse("mailto:jsmith@example.com")
    # user = CalAddress.new(uri)
    # user.uri.opaque  #=> "jsmith@example.com"
    def initialize(@uri : URI)
    end

    private def convert_params(hash : Hash(String, String))
      output = {} of String => String
      hash.each do |k,v|
        output[convert_string(k)] = v.downcase
      end
      output
    end

    private def convert_string(string : String)
      string = string.downcase
      string.gsub("-", "_")
    end
  end
end
