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
    delete_all_remote_branches # Prune is not supported by rugged! Deleting all remote refs and re-fetch
    delete_all_tags
    @repository.remotes['origin'].fetch
    @repository.remotes['origin'].fetch 'refs/tags/*:refs/tags/*'

    # Updates all branches
    @repository.branches.each_name(:remote) do |branch|
      local_branch_name = branch[/origin\/(.*)/, 1]
      checkout_target_directory = File.join(@repository.workdir, "branches", local_branch_name)
      FileUtils::mkdir_p checkout_target_directory
      @repository.checkout(branch, strategy: :force, target_directory: checkout_target_directory)
    end

    # Deletes branches that are already deleted in remote
    existing_branches.each do |branch|
      unless @repository.branches.exists? "origin/#{branch}"
        FileUtils.rm_rf File.join(@repository.workdir, 'branches', branch)
      end
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
  end

  private

  def existing_branches
    Dir.entries(File.join(@repository.workdir, 'branches')).select { |branch| branch != "." && branch != ".." }
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
