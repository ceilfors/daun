class RefDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added
    added_keys = @after.keys - @before.keys
    added_keys.collect { |k| k.to_s }
  end
end
