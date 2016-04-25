require 'git'

class GitGrok

  def init(remote_url, destination)
    g = Git.init(destination)
    g.add_remote('origin', remote_url)
    g.fetch
  end

  def checkout(repository)
    g = Git.open(repository)
    g.branches.remote.each do |branch|
      Git.clone(g.remote('origin').url, "#{repository}/branches/#{branch.name}", :branch => branch.name)
    end
  end
end
