class RefDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added(type = nil)
    keys = (@after.keys - @before.keys).collect { |k| k.to_s }
    type ? keys.select { |k| k.start_with? "refs/#{type.to_s}"} : keys
  end
end
