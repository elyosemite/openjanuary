require "thor"

module January
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "project SUBCOMMAND", "Manage projects"
    subcommand "project", ProjectCommands

    desc "era SUBCOMMAND", "Manage eras of the active project"
    subcommand "era", EraCommands

    desc "board SUBCOMMAND", "Manage boards, their columns and their cards"
    subcommand "board", BoardCommands

    map %w[-v --version] => :version

    desc "version", "Print the OpenJanuary version"
    def version
      puts January::VERSION
    end
  end
end
