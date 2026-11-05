require "thor"

module January
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "project SUBCOMMAND", "Manage projects"
    subcommand "project", ProjectCommands

    desc "version", "Print the OpenJanuary version"
    def version
      puts January::VERSION
    end
  end
end
