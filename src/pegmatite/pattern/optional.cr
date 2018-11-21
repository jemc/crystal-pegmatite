module Pegmatite
  # Pattern::Optional specifies that a pattern that can either match or not.
  #
  # If the child pattern doesn't match, zero bytes are consumed.
  # Otherwise, the result of the child pattern is returned directly.
  # This pattern will never fail.
  class Pattern::Optional < Pattern
    def initialize(@child : Pattern)
    end
    
    def description
      "optional #{@child.description}"
    end
    
    def match(source, offset, tokenize) : MatchResult
      length, result = @child.match(source, offset, tokenize)
      
      if result.is_a?(MatchOK)
        {length, result}
      else
        {0, nil}
      end
    end
  end
end
