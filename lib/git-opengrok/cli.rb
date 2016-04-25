require 'thor'
require 'git-opengrok/gitgrok'

class GitOpenGrok::CLI < Thor

  desc "init remote_url destination", "Initialize a gitgrok directory"
  def init(remote_url, destination)
    GitGrok.new.init remote_url, destination
  end

  desc "checkout", "Checks out git working tree as per gitgrok configuration"
  option :directory
  def checkout()
    GitGrok.new.checkout options[:directory]
  end
end
