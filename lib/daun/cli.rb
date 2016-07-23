require 'thor'
require 'daun'

module Daun
  # All daun cli subcommands are made available by this class.
  class CLI < Thor
    desc 'init remote_url destination', 'Initialize a daun directory'

    def init(remote_url, destination)
      Daun::RuggedDaun.new(destination).init(remote_url)
    end

    desc 'checkout', 'Checks out git working tree as per daun configuration'
    option :directory, default: '.'

    def checkout
      Daun::RuggedDaun.new(options[:directory]).checkout
    end
  end
end
