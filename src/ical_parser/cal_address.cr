require "json"
require "./uri"

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

    module RoleConverter
      def self.from_json(value : JSON::PullParser) : Role
        Role.from_string(value.read_string)
      end

      def self.to_json(value : Role, json : JSON::Builder)
        value.to_s.to_json(json)
      end
    end

    module CUTypeConverter
      def self.from_json(value : JSON::PullParser) : CUType
        CUType.from_string(value.read_string)
      end

      def self.to_json(value : CUType, json : JSON::Builder)
        value.to_s.to_json(json)
      end
    end

    module PartStatConverter
      def self.from_json(value : JSON::PullParser) : PartStat
        PartStat.from_string(value.read_string)
      end

      def self.to_json(value : PartStat, json : JSON::Builder)
        value.to_s.to_json(json)
      end
    end

    JSON.mapping(
      uri: { type: URI, converter: URIConverter },
      cutype: { type: CUType, converter: CUTypeConverter, default: CUType::Individual },
      role: { type: Role, converter: RoleConverter, default: Role::ReqParticipant },
      part_stat: { type: PartStat, key: "partstat", converter: PartStatConverter, default: PartStat::NeedsAction },
      delegated_from: { type: Array(CalAddress), key: "delegated-from", default: [] of CalAddress },
      delegated_to: { type: Array(CalAddress), key: "delegated-to", default: [] of CalAddress },
      member: { type: Array(CalAddress), default: [] of CalAddress },
      sent_by: { type: CalAddress?, key: "sent-by" },
      rsvp: { type: Bool, default: false },
      common_name: { type: String?, key: "cn" },
      dir: { type: URI?, converter: URIConverter }
    )

    @member = [] of CalAddress
    @cutype = CUType::Individual
    @role = Role::ReqParticipant
    @part_stat = PartStat::NeedsAction
    @delegated_from = [] of CalAddress
    @delegated_to = [] of CalAddress
    @rsvp = false

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
