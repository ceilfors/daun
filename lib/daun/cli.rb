require 'thor'
require 'daun/rugged_daun'

class Daun::CLI < Thor

  desc "init remote_url destination", "Initialize a daun directory"
  def init(remote_url, destination)
    RuggedDaun.new.init remote_url, destination
  end

  desc "checkout", "Checks out git working tree as per daun configuration"
  option :directory
  def checkout()
    RuggedDaun.new.checkout options[:directory]
  end
end
