require 'thor'
require 'daun'
require 'rugged'
require 'git_clone_url'

module Daun
  # All daun cli subcommands are made available by this class.
  class CLI < Thor
    desc 'init remote_url destination', 'Initialize a daun directory'

    def init(remote_url, destination)
      Daun::RuggedDaun.new(destination).init(remote_url)
    end

    desc 'checkout', 'Checks out git working tree as per daun configuration'
    option :directory, default: '.'
    option :ssh_private_key, default: File.join(ENV['HOME'], '.ssh', 'id_rsa')
    option :ssh_public_key, default: File.join(ENV['HOME'], '.ssh', 'id_rsa.pub')

    def checkout
      rugged_daun = Daun::RuggedDaun.new(options[:directory])
      repository = rugged_daun.repository

      origin = repository.remotes['origin']
      origin_uri = GitCloneUrl.parse(origin.url)

      credentials = nil
      if [nil, 'ssh'].include? origin_uri.scheme
        credentials = Rugged::Credentials::SshKey.new(
            :username   => origin_uri.user,
            :privatekey => options[:ssh_private_key],
            :publickey  => options[:ssh_public_key],
        )
      end

      rugged_daun.checkout credentials
    end
  end
end
