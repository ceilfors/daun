module Daun
  ##
  # Produce git refs differences before and after fetch
  class RefsDiff
    attr_accessor :added_remotes

    # Creates a new instance of `RefsDiff`.
    #
    # @param before [Hash] the refs hash with full refs format as key and commit id as value
    # @param after [Hash] the refs hash with full refs format as key and commit id as value
    def initialize(before, after)
      @before = before
      @after = after
    end

    # Returns all of the refs that have been added after the fetch. These are the refs
    # that exists in `after` but not `before`.
    #
    # @param type [Symbol] :tag for tag refs, :remotes for remote branches, nil for everything
    def added(type = nil)
      keys = (@after.keys - @before.keys).collect(&:to_s)
      filter(keys, type)
    end

    # Returns all of the refs that have been updated after the fetch. Updated refs
    # are detected when refs exists in both `before` and `after` but is having a
    # different commit id in the `Hash`.
    #
    # @param type [Symbol] :tag for tag refs, :remotes for remote branches, nil for everything
    def updated(type = nil)
      keys = (@after.keys + @before.keys)
                 .group_by { |k| k }
                 .select { |k, k_group| k_group.size > 1 && @before[k] != @after[k] }
                 .keys.collect(&:to_s)
      filter(keys, type)
    end

    # Returns all of the refs that have been deleted after the fetch. These are the
    # refs that exists in `before` but not `after`
    #
    # @param type [Symbol] :tag for tag refs, :remotes for remote branches, nil for everything
    def deleted(type = nil)
      keys = (@before.keys - @after.keys).collect(&:to_s)
      filter(keys, type)
    end

    private

    def filter(keys, type)
      !type.nil? ? keys.select { |k| k.start_with? "refs/#{type}" } : keys
    end
  end
end
