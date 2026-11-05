require "thor"

module January
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "project SUBCOMMAND", "Manage projects"
    subcommand "project", ProjectCommands

    desc "column SUBCOMMAND", "Manage columns of the active project"
    subcommand "column", ColumnCommands

    desc "card SUBCOMMAND", "Manage cards of the active project"
    subcommand "card", CardCommands

    desc "era SUBCOMMAND", "Manage eras of the active project"
    subcommand "era", EraCommands

    map %w[-v --version] => :version

    desc "version", "Print the OpenJanuary version"
    def version
      puts January::VERSION
    end
  end
end
