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

    # Creates a new CalAddress object with the specified URI and parameters.
    #
    # uri = URI.parse("mailto:jsmith@example.com")
    # params = { "RSVP" => "TRUE" }
    # user = CalAddress.new(uri, params)
    # user.uri.opaque  #=> "jsmith@example.com"
    def initialize(@uri : URI, params : Hash(String, String))
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
