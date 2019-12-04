module Pegmatite
  # Pattern::End is used to mark the end of a dynamic delimiter,
  #
  # If the child pattern produces tokens, those tokens will be passed as-is.
  #
  # Returns the result of the child pattern's parsing.
  class Pattern::End < Pattern
    def initialize(@child : Pattern, @label : Symbol)
    end

    def inspect(io)
      io << "end(\""
      @label.inspect(io)
      io << "\")"
    end

    def dsl_name
      "end"
    end

    def description
      @label.inspect
    end

    def _match(source, offset, state) : MatchResult
      length, result = @child.match(source, offset, state)
      return {length, result} if !result.is_a?(MatchOK)

      last_delim = state.delimiters.last

      val = source[offset...(offset+length)]

      if last_delim[0] != @label || last_delim[1] != val
        state.observe_fail(offset + length, @child)
        return {length, result}
      end

      state.delimiters.pop

      {length, result}
    end
  end
end
