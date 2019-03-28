struct Enum
  def self.parse?(string : String) : self?
    {% begin %}
      case string.gsub('-', '_').camelcase.downcase
      {% for member in @type.constants %}
        when {{member.stringify.camelcase.downcase}}
          {{@type}}::{{member}}
      {% end %}
      else
        nil
      end
    {% end %}
  end

  def to_json(json : JSON::Builder)
    self.to_s.underscore.gsub('_', '-').upcase.to_json(json)
  end
end

module IcalParser
  class CalAddress
    # Possible values for the [Participation Role](https://tools.ietf.org/html/rfc5545#section-3.2.16) of a calendar user.
    enum Role
      Chair
      ReqParticipant
      OptParticipant
      NonParticipant

      def self.parse(string : String) : self
        parse?(string) || ReqParticipant
      end
    end

    # Possible calendar user [types](https://tools.ietf.org/html/rfc5545#section-3.2.3)
    enum CUType
      Individual
      Group
      Resource
      Room
      Unknown

      def self.parse(string : String) : self
        parse?(string) || Individual
      end
    end

    # Possible values for [Participation Status](https://tools.ietf.org/html/rfc5545#section-3.2.12) of a calendar user.
    enum PartStat
      NeedsAction
      Accepted
      Declined
      Tentative
      Delegated

      def self.parse(string : String) : self
        parse?(string) || NeedsAction
      end
    end
  end

  struct RecurrenceRule
    enum Freq
      Secondly
      Minutely
      Hourly
      Daily
      Weekly
      Monthly
      Yearly

      def self.from_string(string : String)
        case string
        when "secondly"
          Secondly
        when "minutely"
          Minutely
        when "hourly"
          Hourly
        when "daily"
          Daily
        when "weekly"
          Weekly
        when "monthly"
          Monthly
        when "yearly"
          Yearly
        else
          raise "Invalid Recurrence Rule FREQ value"
        end
      end
    end
  end
end
