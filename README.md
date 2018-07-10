# iCal

A Crystal library for parsing and generating calendar data with the iCalendar Specification.

DO NOT USE. Still a work in progress, many changes to come.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  iCal:
    github: HCLarsen/ical_parser.cr
```

## Usage

```crystal
require "iCal"
```

### Parsing

The ICSStream.read method will read an ICS stream either from a local file, or a remote address. To read a local file, pass in a string of the local filename and path.

```crystal
filename = File.join(File.dirname(__FILE__), "files", "FIFA_World_Cup_2018.ics")
calendar = ICSStream.read(filename)
calendar.class  #=> Calendar
```

In the case of a remote stream, pass in a URI object with the address of the stream.

```crystal
address = "https://people.trentu.ca/rloney/files/Canada_Holidays.ics"
uri = URI.parse(address)
calendar = ICSStream.read(uri)  #=> #<IcalParser::Calendar:0x10868a5c0>
calendar.class  #=> Calendar
```
In most cases, an iCalendar stream will only contain one calendar object. However, the specification does allow for multiple calendar objects to be sequentially grouped in a single stream. If you are reading such a stream, the ICSStream.read method will only return the first calendar object. If you are working with a stream that may have multiple calendar objects, it's best to use the ICSStream.read_calendars method instead to get an array of Calendar objects.

```crystal
filename = File.join(File.dirname(__FILE__), "files", "FIFA_World_Cup_2018.ics")
calendars = ICSStream.read_calendars(filename)  #=> [#<IcalParser::Calendar:0x10e733100]
calendars.class  #=> Array(Calendar)
```

## Contributing

1. Fork it ( https://github.com/HCLarsen/ical_parser.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [HCLarsen](https://github.com/HCLarsen) Chris Larsen - creator, maintainer
