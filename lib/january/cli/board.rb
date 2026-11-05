require "io/console"

module January
  class CLI < Thor
    desc "board", "Show the active project as a board"
    option :all, type: :boolean, desc: "Show every card, regardless of era"
    def board
      project = workspace.active_project
      era = project.current_era
      puts ["Project: #{project.name}", (era ? "Era: #{era.name}" : nil)].compact.join("    ")
      puts
      cards = project.board_cards(all: options[:all])
      puts BoardRenderer.new(columns: project.columns, cards: cards, width: terminal_width).render
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
