module Pegmatite
  # Pattern::Begin is used to dynamically create a start delimiter,
  # usually for the purposes of dynamically constraining the scope of a pattern.
  #
  # If the child pattern produces tokens, those tokens will be passed as-is.
  #
  # Returns the result of the child pattern's parsing.
  class Pattern::Begin < Pattern
    def initialize(@child : Pattern, @label : Symbol)
    end

    def inspect(io)
      io << "begin(\""
      @label.inspect(io)
      io << "\")"
    end

    def dsl_name
      "begin"
    end

    def description
      @label.inspect
    end

    def _match(source, offset, state) : MatchResult
      length, result = @child.match(source, offset, state)
      return {length, result} if !result.is_a?(MatchOK)

      val = source[offset...(offset+length)]

      state.delimiters.push({@label, val})

      {length, result}
    end
  end
end
