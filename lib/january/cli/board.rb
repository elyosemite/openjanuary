require "io/console"

module January
  class CLI < Thor
    desc "board", "Show the active project as a board"
    def board
      project = workspace.active_project
      puts "Project: #{project.name}"
      puts
      puts BoardRenderer.new(columns: project.columns, cards: project.cards, width: terminal_width).render
    end

    no_commands do
      def workspace
        @workspace ||= Workspace.new
      end

      def terminal_width
        (ENV["COLUMNS"] || IO.console&.winsize&.last || 80).to_i
      end
    end
  end
end
