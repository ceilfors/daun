# Produce git refs differences before and after fetch
class RefsDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added(type = nil)
    keys = (@after.keys - @before.keys).collect(&:to_s)
    filter(keys, type)
  end

  def updated(type = nil)
    keys = (@after.keys + @before.keys)
               .group_by { |k| k }
               .select { |k, k_group| k_group.size > 1 && @before[k] != @after[k] }
               .keys.collect(&:to_s)
    filter(keys, type)
  end

  def deleted(type = nil)
    keys = (@before.keys - @after.keys).collect(&:to_s)
    filter(keys, type)
  end

  private

  def filter(keys, type)
    !type.nil? ? keys.select { |k| k.start_with? "refs/#{type}" } : keys
  end
end
