Fixtures::JSON = Pegmatite::DSL.define do
  # Forward-declare `array` and `object` to refer to them before defining them.
  array  = declare
  object = declare
  
  # Define what optional whitespace looks like.
  s = (char(' ') | char('\t') | char('\r') | char('\n')).repeat
  
  # Define what a number looks like.
  digit19 = range('1', '9')
  digit = range('0', '9')
  digits = digit.repeat(1)
  int =
    (char('-') >> digit19 >> digits) |
    (char('-') >> digit) |
    (digit19 >> digits) |
    digit
  frac = char('.') >> digits
  exp = (char('e') | char('E')) >> (char('+') | char('-')).maybe >> digits
  number = (int >> frac.maybe >> exp.maybe).named(:number)
  
  # Define what a string looks like.
  hex = digit | range('a', 'f') | range('A', 'F')
  string_char =
    str("\\\"") | str("\\\\") | str("\\|") |
    str("\\b") | str("\\f") | str("\\n") | str("\\r") | str("\\t") |
    (str("\\u") >> hex >> hex >> hex >> hex) |
    (~char('"') >> ~char('\\') >> range(' ', 0x10FFFF_u32))
  string = char('"') >> string_char.repeat.named(:string) >> char('"')
  
  # Define what constitutes a value.
  value =
    str("null").named(:null) |
    str("true").named(:true) |
    str("false").named(:false) |
    number | string | array | object
  
  # Define what an array is, in terms of zero or more values.
  values = value >> s >> (char(',') >> s >> value).repeat
  array.define \
    (char('[') >> s >> values.maybe >> s >> char(']')).named(:array)
  
  # Define what an object is, in terms of zero or more key/value pairs.
  pair = (string >> s >> char(':') >> s >> value).named(:pair)
  pairs = pair >> s >> (char(',') >> s >> pair).repeat
  object.define \
    (char('{') >> s >> pairs.maybe >> s >> char('}')).named(:object)
  
  # A JSON document is an array or object with optional surrounding whitespace.
  (s >> (array | object) >> s).then_eof
end
