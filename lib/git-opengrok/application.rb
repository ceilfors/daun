module GitOpenGrok

  class Application

    class << self
      def application
        @application = GitOpenGrok::Application.new
      end
    end

    # Runs the application by parsing command line arguments and delegating it to the subcommands.
    def run
    end
  end
end