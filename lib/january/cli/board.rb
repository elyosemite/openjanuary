require "io/console"
require "thor"

module January
  class CLI < Thor
    class BoardCommands < Thor
      default_task :show

      def self.exit_on_failure?
        true
      end

      desc "show", "Show the active board (default)"
      option :all, type: :boolean, desc: "Show every card, regardless of era"
      def show
        project = workspace.active_project
        board = project.active_board
        era = board.current_era
        header = ["Project: #{project.name}", "Board: #{board.name}", (era ? "Era: #{era.name}" : nil)]
        puts header.compact.join("    ")
        puts
        cards = board.board_cards(all: options[:all])
        puts BoardRenderer.new(columns: board.columns, cards: cards, width: terminal_width).render
      end

      desc "add NAME", "Create a board in the active project"
      def add(name)
        board = update_project { |project| project.add_board(name) }
        puts "Created board '#{board.name}'. Run 'january board use #{board.name}' to switch to it."
      end

      desc "list", "List the boards of the active project (* marks the active one)"
      def list
        project = workspace.active_project
        project.board_names.each { |n| puts "#{n == project.active_board_name ? '*' : ' '} #{n}" }
      end

      desc "use NAME", "Switch the active board"
      def use(name)
        board = update_project { |project| project.use_board(name) }
        puts "Now using board '#{board.name}'."
      end

      desc "remove NAME", "Delete a board and everything in it"
      option :yes, type: :boolean, aliases: "-y", desc: "Skip the confirmation"
      def remove(name)
        board = workspace.active_project.find_board(name)
        unless options[:yes] || confirm?("Remove board '#{board.name}' and all its cards? (y/N) ")
          return puts("Aborted.")
        end

        update_project { |project| project.remove_board(board.name) }
        puts "Removed board '#{board.name}'."
      end

      desc "move COLUMN --to POSITION", "Move a column of the active board to a 1-based position"
      option :to, type: :numeric, required: true, desc: "Target position, starting at 1"
      def move(name)
        position = options[:to].to_i
        column = workspace.update_board { |board| board.move_column(name, position) }
        puts "Moved column '#{column}' to position #{position}."
      end

      private

      def update_project(&block)
        workspace.update_project(workspace.active_project.name, &block)
      end

      def confirm?(question)
        print question
        $stdout.flush
        $stdin.gets.to_s.strip.downcase.start_with?("y")
      end

      def workspace
        @workspace ||= Workspace.new
      end

      def terminal_width
        (ENV["COLUMNS"] || IO.console&.winsize&.last || 80).to_i
      end
    end
  end
end
