# IANA, non-standard, language, calendar user type, group or list membership, participation role, participation status, RSVP expectation, delegatee, delegator, sent by, common name, or directory entry

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
    # Possible values for the [Participation Role](https://tools.ietf.org/html/rfc5545#section-3.2.16) of a calendar user.
    enum Role
      Chair
      ReqParticipant
      OptParticipant
      NonParticipant

      def self.from_string(string : String)
        case string
        when "CHAIR"
          Chair
        when "OPT-PARTICIPANT"
          OptParticipant
        when "NON-PARTICIPANT"
          NonParticipant
        else
          ReqParticipant
        end
      end
    end

    # Possible calendar user [types](https://tools.ietf.org/html/rfc5545#section-3.2.3)
    enum CUType
      Individual
      Group
      Resource
      Room
      Unknown

      def self.from_string(string : String)
        case string
        when "GROUP"
          Group
        when "RESOURCE"
          Resource
        when "ROOM"
          Room
        when "UNKNOWN"
          Unknown
        else
          Individual
        end
      end
    end

    # Possible values for [Participation Status](https://tools.ietf.org/html/rfc5545#section-3.2.12) of a calendar user.
    enum PartStat
      NeedsAction
      Accepted
      Declined
      Tentative
      Delegated

      def self.from_string(string : String)
        case string
        when "ACCEPTED"
          Accepted
        when "DECLINED"
          Declined
        when "TENTATIVE"
          Tentative
        when "DELEGATED"
          Delegated
        else
          NeedsAction
        end
      end
    end

    property uri : URI

    property cutype = CUType::Individual
    property role = Role::ReqParticipant
    property part_stat = PartStat::NeedsAction
    property rsvp = false
    property sent_by : CalAddress?
    property member = [] of CalAddress
    property delegated_to = [] of CalAddress
    property delegated_from = [] of CalAddress
    property language : String?
    property common_name : String?
    property dir : URI?

    # Creates a new CalAddress object with the specified URI.
    #
    # uri = URI.parse("mailto:jsmith@example.com")
    # user = CalAddress.new(uri)
    # user.uri.opaque  #=> "jsmith@example.com"
    def initialize(@uri : URI)
    end

    def_equals @uri

    private def convert_params(hash : Hash(String, String))
      output = {} of String => String
      hash.each do |k, v|
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
