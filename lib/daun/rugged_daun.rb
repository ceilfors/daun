require 'rugged'

class RuggedDaun

  def init(remote_url, destination)
    repo = Rugged::Repository.init_at(destination)
    repo.remotes.create('origin', remote_url)
    repo.fetch 'origin'
  end

  def checkout(repository)
    repo = Rugged::Repository.new(repository)
    repo.branches.each_name(:remote) do |branch|
      local_branch_name = branch[/origin\/(.*)/, 1]
      Rugged::Repository.clone_at(repo.remotes['origin'].url, "#{repository}/branches/#{local_branch_name}", {:checkout_branch => local_branch_name})
    end

    repo.tags.each do |tag|
      tag_repo = Rugged::Repository.clone_at(repo.remotes['origin'].url, "#{repository}/tags/#{tag.name}")
      tag_repo.reset tag.target.oid, :hard # KLUDGE checkout tag.target.oid is not working as expected
    end
  end
end
