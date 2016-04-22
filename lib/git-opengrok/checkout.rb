module GitOpenGrok
  class Checkout
    def initialize(destination, remote_url)
      @destination = destination
      @remote_url = remote_url
    end

    def apply
      root = Git.init(@destination)
      root.add_remote('origin', @remote_url)
      root.fetch
      root.branches.remote.each do |branch|
        Git.clone(@remote_url, "#{@destination}/branches/#{branch.name}", :branch => branch.name)
      end
    end
  end
end
