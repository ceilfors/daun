require 'thor'
require 'daun/rugged_daun'

module Daun
  # Daun CLI. All commands are made available by this class.
  class CLI < Thor
    desc 'init remote_url destination', 'Initialize a daun directory'

    def init(remote_url, destination)
      RuggedDaun.new(destination).init(remote_url)
    end

    desc 'checkout', 'Checks out git working tree as per daun configuration'
    option :directory

    def checkout
      RuggedDaun.new(options[:directory]).checkout
    end
  end
end
