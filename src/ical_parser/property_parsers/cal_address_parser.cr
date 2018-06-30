require "uri"

module IcalParser
  class CalAddressParser < ValueParser(CalAddress)
    def parse(string : String, params = {} of String => String, options = [] of EventParser::Option) : T
      uri = URI.parse(string)
      address = CalAddress.new(uri)
      address.rsvp = true if params["RSVP"]? == "TRUE"
      address.common_name = params["CN"]?

      if string = params["SENT-BY"]?
        address.sent_by = CalAddress.new(URI.parse(string))
      end

      if string = params["MEMBER"]?
        array = string.split(",")
        array.each do |member|
          member = member.strip('"')
          address.member << CalAddress.new(URI.parse(member))
        end
      end

      if string = params["DELEGATED-TO"]?
        array = string.split(",")
        array.each do |delegatee|
          delegatee = delegatee.strip('"')
          address.delegated_to << CalAddress.new(URI.parse(delegatee))
        end
      end

      if string = params["DELEGATED-FROM"]?
        array = string.split(",")
        array.each do |delegatee|
          delegatee = delegatee.strip('"')
          address.delegated_from << CalAddress.new(URI.parse(delegatee))
        end
      end

      if string = params["DIR"]?
        address.dir = URI.parse(string.strip('"'))
      end

      if string = params["ROLE"]?
        address.role = CalAddress::Role.from_string(string)
      end

      if string = params["PARTSTAT"]?
        address.part_stat = CalAddress::PartStat.from_string(string)
      end

      if string = params["CUTYPE"]?
        address.cutype = CalAddress::CUType.from_string(string)
      end

      address
    end
  end
end
