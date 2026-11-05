require "io/console"
require "thor"

module January
  class CLI < Thor
    class BoardCommands < Thor
      default_task :show

      def self.exit_on_failure?
        true
      end

      desc "show", "Show the active project as a board (default)"
      option :all, type: :boolean, desc: "Show every card, regardless of era"
      def show
        project = workspace.active_project
        era = project.current_era
        puts ["Project: #{project.name}", (era ? "Era: #{era.name}" : nil)].compact.join("    ")
        puts
        cards = project.board_cards(all: options[:all])
        puts BoardRenderer.new(columns: project.columns, cards: cards, width: terminal_width).render
      end

      desc "move COLUMN --to POSITION", "Move a column to a 1-based position"
      option :to, type: :numeric, required: true, desc: "Target position, starting at 1"
      def move(name)
        position = options[:to].to_i
        column = workspace.update_project(workspace.active_project.name) do |project|
          project.move_column(name, position)
        end
        puts "Moved column '#{column}' to position #{position}."
      end

      private

      def workspace
        @workspace ||= Workspace.new
      end

      def terminal_width
        (ENV["COLUMNS"] || IO.console&.winsize&.last || 80).to_i
      end
    end
  end
end
