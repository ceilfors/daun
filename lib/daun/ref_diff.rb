class RefDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added(type = nil)
    keys = (@after.keys - @before.keys).collect { |k| k.to_s }
    type ? keys.select { |k| k.start_with? "refs/#{type}" } : keys
  end

  def updated
    (@after.keys + @before.keys)
        .group_by { |e| e }
        .select { |k, v| v.size > 1 }
        .collect { |k, v| v[0].to_s}
  end
end
