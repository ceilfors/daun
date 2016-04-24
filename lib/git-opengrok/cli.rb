require 'thor'

class GitOpenGrok::CLI < Thor

  desc "init remote_url destination", "Initialize a gitgrok directory"
  def init(remote_url, destination)
    puts remote_url, destination
  end
end
