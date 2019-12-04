module Pegmatite
  # Pattern::Delimiter is used to peek at a stored delimiter value and consume a
  # specific string that matches the delimiter.
  #
  # Parsing will fail if the bytes in the stream don't exactly match the delimiter.
  # Otherwise, the pattern succeeds, consuming the matched bytes.
  class Pattern::Delimiter < Pattern
    def initialize(@label : Symbol)
    end

    def inspect(io)
      io << "delimiter(\""
      @label.inspect(io)
      io << "\")"
    end

    def dsl_name
      "delimiter"
    end

    def description
      @label.inspect
    end

    def _match(source, offset, state) : MatchResult
      last_delim = state.delimiters.select { |delim|
        delim[0] == @label
      }.last

      if !last_delim
        return {0, self}
      end

      delim_val = last_delim[1]
      delim_size = delim_val.bytesize.as(Int32)

      # Like Literal, we use some ugly patterns here for optimization
      return {0, self} if source.bytesize < (offset + delim_size)
      i = 0
      while i < delim_size
        return {0, self} \
          if delim_val.unsafe_byte_at(i) != source.unsafe_byte_at(offset + i)
        i += 1
      end

      {delim_val.bytesize, nil}
    end
  end
end
