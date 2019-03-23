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

      def self.parse(string : String) : self?
        {% begin %}
          case string.gsub('-', '_').camelcase.downcase
          {% for member in @type.constants %}
            when {{member.stringify.camelcase.downcase}}
              {{@type}}::{{member}}
          {% end %}
          else
            ReqParticipant
          end
        {% end %}
      end

      def to_json(json : JSON::Builder)
        self.to_s.underscore.gsub('_', '-').upcase.to_json(json)
      end
    end

    # Possible calendar user [types](https://tools.ietf.org/html/rfc5545#section-3.2.3)
    enum CUType
      Individual
      Group
      Resource
      Room
      Unknown

      def self.parse(string : String) : self?
        {% begin %}
          case string.gsub('-', '_').camelcase.downcase
          {% for member in @type.constants %}
            when {{member.stringify.camelcase.downcase}}
              {{@type}}::{{member}}
          {% end %}
          else
            Individual
          end
        {% end %}
      end

      def to_json(json : JSON::Builder)
        self.to_s.underscore.gsub('_', '-').upcase.to_json(json)
      end
    end

    # Possible values for [Participation Status](https://tools.ietf.org/html/rfc5545#section-3.2.12) of a calendar user.
    enum PartStat
      NeedsAction
      Accepted
      Declined
      Tentative
      Delegated

      def self.parse(string : String) : self?
        {% begin %}
          case string.gsub('-', '_').camelcase.downcase
          {% for member in @type.constants %}
            when {{member.stringify.camelcase.downcase}}
              {{@type}}::{{member}}
          {% end %}
          else
            NeedsAction
          end
        {% end %}
      end

      def to_json(json : JSON::Builder)
        self.to_s.underscore.gsub('_', '-').upcase.to_json(json)
      end
    end

    JSON.mapping(
      uri: { type: URI, converter: URIConverter },
      cutype: { type: CUType?, getter: false },
      role: { type: Role?, getter: false },
      part_stat: { type: PartStat?, getter: false, key: "partstat" },
      member: { type: Array(CalAddress)?, getter: false },
      delegated_from: { type: Array(CalAddress)?, key: "delegated-from", getter: false },
      delegated_to: { type: Array(CalAddress)?, key: "delegated-to", getter: false },
      sent_by: { type: CalAddress?, key: "sent-by" },
      rsvp: { type: Bool? },
      common_name: { type: String?, key: "cn" },
      dir: { type: URI?, converter: URIConverter }
    )

    getter(member) { [] of CalAddress }
    getter(delegated_from) { [] of CalAddress }
    getter(delegated_to) { [] of CalAddress }

    # Creates a new CalAddress object with the specified URI.
    #
    # uri = URI.parse("mailto:jsmith@example.com")
    # user = CalAddress.new(uri)
    # user.uri.opaque  #=> "jsmith@example.com"
    def initialize(@uri : URI)
    end

    def_equals @uri

    def cutype
      @cutype || CUType::Individual
    end

    def role
      @role || Role::ReqParticipant
    end

    def part_stat
      @part_stat || PartStat::NeedsAction
    end

    def rsvp
      @rsvp || false
    end
  end
end
