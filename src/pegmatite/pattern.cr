abstract class Pegmatite::Pattern
  include DSL::Methods
  
  # A successful match returns zero, one, or many tokens.
  # We treat zero (Nil) and one (Token) as special cases so that we don't have
  # to pay to allocate an Array(Token) on every single match method call.
  alias MatchOK = Nil | Token | Array(Token)
  
  # Calling a match method will return the number of bytes consumed,
  # followed in the tuple by either MatchOK or a Pattern instance,
  # the latter indicating that the indicated pattern failed to match.
  alias MatchResult = {Int32, MatchOK | Pattern}
  
  # Higher-level methods may choose to represent errors as exceptions,
  # created in part by getting the description of the Pattern that failed.
  class MatchError < Exception
    def initialize(pattern : Pattern, offset : Int32)
      description = pattern.description
      super("unexpected byte at offset #{offset}; expected: #{description}")
    end
  end
end

require "./pattern/*"
