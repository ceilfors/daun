require 'rugged'
require 'fileutils'

class RuggedDaun

  def initialize repository_path
    @repository = Rugged::Repository.init_at(repository_path)
  end

  def init(remote_url)
    @repository.remotes.create('origin', remote_url)
  end

  def checkout
    fetch_result = fetch

    # Updates all branches
    @repository.branches.each_name(:remote) do |branch|
      local_branch_name = branch[/origin\/(.*)/, 1]
      checkout_target_directory = File.join(@repository.workdir, "branches", local_branch_name)
      FileUtils::mkdir_p checkout_target_directory
      @repository.checkout(branch, strategy: :force, target_directory: checkout_target_directory)
    end

    fetch_result.deleted_branches.each do |branch|
      FileUtils.rm_rf File.join(@repository.workdir, 'branches', branch)
    end

    @repository.tags.each do |tag|
      checkout_target_directory = File.join(@repository.workdir, "tags", tag.name)
      # TODO Check if git reference difference before deleting
      if File.exists? checkout_target_directory
        # checkout --force is somehow not working to update the tag
        FileUtils.rm_rf checkout_target_directory
      end
      FileUtils::mkdir_p checkout_target_directory
      @repository.checkout(tag.target.oid, strategy: :force, target_directory: checkout_target_directory)
    end

    fetch_result.deleted_tags.each do |tag|
      FileUtils.rm_rf File.join(@repository.workdir, 'tags', tag)
    end
  end

  private

  def fetch
    before_fetch_branches = @repository.branches.each_name.to_a.collect { |branch| branch[/origin\/(.*)/, 1]}
    delete_all_remote_branches # Prune is not supported by rugged! Deleting all remote refs and re-fetch
    before_fetch_tags = @repository.tags.each_name.to_a
    delete_all_tags

    fetch_result = FetchResult.new
    @repository.remotes['origin'].fetch
    after_fetch_branches = @repository.branches.each_name.to_a.collect { |branch| branch[/origin\/(.*)/, 1]}
    after_fetch_tags = @repository.tags.each_name.to_a

    fetch_result.new_branches = after_fetch_branches - before_fetch_branches
    fetch_result.deleted_branches = before_fetch_branches - after_fetch_branches
    fetch_result.existing_branches = before_fetch_branches - fetch_result.new_branches

    fetch_result.new_tags = after_fetch_tags - before_fetch_tags
    fetch_result.deleted_tags = before_fetch_tags - after_fetch_tags
    fetch_result.existing_tags = before_fetch_tags - fetch_result.new_tags

    fetch_result
  end

  class FetchResult

    attr_accessor :new_branches, :deleted_branches, :existing_branches,
                  :new_tags, :deleted_tags, :existing_tags
  end

  def delete_all_remote_branches
    @repository.branches.each_name(:remote) do |branch|
      @repository.branches.delete branch
    end
  end

  def delete_all_tags
    @repository.tags.each_name do |tag|
      @repository.tags.delete tag
    end
  end
end
