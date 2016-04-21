module GitOpenGrok
  class Checkout
    def initialize(destination, remote_url)
      @destination = destination
      @remote_url = remote_url
    end

    def apply
      FileUtils.mkdir_p "#{@destination}/branches/master"
    end
  end
end
