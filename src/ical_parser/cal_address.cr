#IANA, non-standard, language, calendar user type, group or list membership, participation role, participation status, RSVP expectation, delegatee, delegator, sent by, common name, or directory entry

module IcalParser
  class CalAddress
    property calendar_user_type : String?
    property member : String?
    property role : String?
    property participation : String?
    property rsvp : Bool?
    property delegated_to : String?
    property delegated_from : String?
    property language : String?
    property sent_by : String?
    property common_name : String?
    property dir : URI?
    property uri : URI

    def initialize(params : Hash(String, String), @uri : URI)
      params = convert_params(params)
      @calendar_user_type = params["cutype"]?
      @member = params["member"]?
      @role = params["role"]?
      @participation = params["partstat"]?
      @delegated_to = params["delegated_to"]?
      @delegated_from = params["delegated_from"]?
      @language = params["language"]?
      @sent_by = params["sent_by"]?

      if rsvp = params["rsvp"]?
        if rsvp = "TRUE"
          @rsvp = true
        else
          @rsvp = false
        end
      end

      @common_name = params["cn"].split.map{ |w| w.capitalize}.join(" ") if params["cn"]?
      @dir = URI.parse(params["dir"]) if params["dir"]?
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
