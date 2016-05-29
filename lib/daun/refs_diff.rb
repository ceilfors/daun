class RefsDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added(type = nil)
    keys = (@after.keys - @before.keys).collect { |k| k.to_s }
    type ? keys.select { |k| k.start_with? "refs/#{type}" } : keys
  end

  def updated(type = nil)
    keys = (@after.keys + @before.keys)
        .group_by { |k| k }
        .select { |k, k_group| k_group.size > 1 && @before[k] != @after[k] }
        .collect { |k, k_group| k.to_s }
    type ? keys.select { |k| k.start_with? "refs/#{type}" } : keys
  end
end
