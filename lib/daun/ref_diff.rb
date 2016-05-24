class RefDiff

  attr_accessor :added_remotes

  def initialize(before, after)
    @before = before
    @after = after
  end

  def added
    @after
  end
end
