require "./pegmatite/*"

module Pegmatite
  VERSION = "0.1.0"
  
  # A token is a triple containing a name, a start offset, and end offset,
  # representing a named pattern that was matched within the overall pattern.
  alias Token = {Symbol, Int32, Int32}
  
  # Return the array of tokens resulting from executing the given pattern
  # grammar over the given source string, starting from the given offset.
  # Raises a Pattern::MatchError if parsing fails.
  def self.tokenize(
    pattern : Pattern,
    source : String,
    offset = 0,
  ) : Array(Token)
    length, result = pattern.match(source, offset, true)
    
    case result
    when Pattern
      raise Pattern::MatchError.new(result, length)
    when Token
      [result]
    when Array(Token)
      result
    else
      [] of Token
    end
  end
  
  # Given a flat array of tokens, build a nested tree where each node is built
  # by the given proc from the "parent" token and zero or more child nodes.
  #
  # Traversal is depth-first. That is, each child is built before its parent,
  # and the resulting node for each child is given to the parent for building.
  #
  # Building is delegated to the given proc, which cannot be a block due to
  # type system and/or syntax limitations in Crystal with `forall` type vars.
  # The type returned by the given proc must be treated as always the same (X).
  def self.build_tree(
    tokens : Array(Token),
    proc : Proc(Token, Array(X), X)
  ) : X forall X
    # Run build_tree_inner with offset zero, discarding the returned offset.
    offset, result = build_tree_inner(tokens, 0, proc)
    result
  end
  
  private def self.build_tree_inner(
    tokens : Array(Token),
    offset : Int32,
    proc : Proc(Token, Array(X), X),
  ) : {Int32, X} forall X
    # Get the main token, bailing out if initial offset is out of bounds.
    return {0, proc.call({:_, 0, 0}, [] of X)} if tokens.size <= offset
    token = tokens.at(offset)
    
    # Visit all "children" of the main token, accumulating the results.
    children = [] of X
    offset += 1
    while offset < tokens.size
      break if tokens.at(offset)[2] > token[2]
      offset, result = build_tree_inner(tokens, offset, proc)
      children << result
      offset += 1
    end
    
    # Yield to the proc to construct the result from the token and children.
    {offset - 1, proc.call(token, children)}
  end
end
