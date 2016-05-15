require 'rugged'
require 'fileutils'

class RuggedDaun

  def init(remote_url, destination)
    repo = Rugged::Repository.init_at(destination)
    repo.remotes.create('origin', remote_url)
  end

  def checkout(repository)
    repo = Rugged::Repository.new(repository)

    # Prune is not supported by rugged! Deleting all remote refs and re-fetch
    repo.branches.each_name(:remote) do |branch|
      repo.branches.delete branch
    end
    repo.remotes['origin'].fetch

    # Updates all branches
    repo.branches.each_name(:remote) do |branch|
      local_branch_name = branch[/origin\/(.*)/, 1]
      checkout_target_directory = "#{repository}/branches/#{local_branch_name}"
      FileUtils::mkdir_p checkout_target_directory
      repo.checkout(branch, strategy: :force, target_directory: checkout_target_directory)
    end

    # Deletes branches that are already deleted in remote
    existing_branches(repository).each do |branch|
      unless repo.branches.exists? "origin/#{branch}"
        FileUtils.rm_rf File.join(repository, 'branches', branch)
      end
    end

    repo.tags.each do |tag|
      tag_repo = Rugged::Repository.clone_at(repo.remotes['origin'].url, "#{repository}/tags/#{tag.name}")
      tag_repo.reset tag.target.oid, :hard # KLUDGE checkout tag.target.oid is not working as expected
    end
  end

  private

  def existing_branches repository
    Dir.entries(File.join(repository, 'branches')).select { |branch| branch != "." && branch != ".." }
  end
end
