class RefDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added(type = nil)
    added_keys = @after.keys - @before.keys
    added_keys = added_keys.collect { |k| k.to_s }
    type ? added_keys.select { |k| k.start_with? "refs/#{type.to_s}"} : added_keys
  end
end
