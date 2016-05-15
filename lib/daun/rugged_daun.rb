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
    # Prune is not supported by rugged! Deleting all remote refs and re-fetch
    @repository.branches.each_name(:remote) do |branch|
      @repository.branches.delete branch
    end
    @repository.remotes['origin'].fetch

    # Updates all branches
    @repository.branches.each_name(:remote) do |branch|
      local_branch_name = branch[/origin\/(.*)/, 1]
      checkout_target_directory = "#{@repository.workdir}/branches/#{local_branch_name}"
      FileUtils::mkdir_p checkout_target_directory
      @repository.checkout(branch, strategy: :force, target_directory: checkout_target_directory)
    end

    # Deletes branches that are already deleted in remote
    existing_branches(@repository.workdir).each do |branch|
      unless @repository.branches.exists? "origin/#{branch}"
        FileUtils.rm_rf File.join(@repository.workdir, 'branches', branch)
      end
    end

    @repository.tags.each do |tag|
      tag_repo = Rugged::Repository.clone_at(@repository.remotes['origin'].url, "#{@repository.workdir}/tags/#{tag.name}")
      tag_repo.reset tag.target.oid, :hard # KLUDGE checkout tag.target.oid is not working as expected
    end
  end

  private

  def existing_branches repository
    Dir.entries(File.join(repository, 'branches')).select { |branch| branch != "." && branch != ".." }
  end
end
