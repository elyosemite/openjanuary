require "thor"

module January
  class CLI < Thor
    class ColumnCommands < Thor
      def self.exit_on_failure?
        true
      end

      desc "add NAME", "Add a column to the active project"
      def add(name)
        column = update { |project| project.add_column(name) }
        puts "Added column '#{column}'."
      end

      desc "list", "List the columns of the active project"
      def list
        columns = workspace.active_board.columns
        return puts("No columns yet. Run 'january column add NAME'.") if columns.empty?

        columns.each_with_index { |column, index| puts "#{index + 1}. #{column}" }
      end

      desc "remove NAME", "Remove a column from the active project"
      option :move_to, desc: "Move its cards to this column before removing"
      option :force, type: :boolean, desc: "Delete its cards along with the column"
      def remove(name)
        column = update do |project|
          project.remove_column(name, force: options[:force], move_to: options[:move_to])
        end
        puts "Removed column '#{column}'."
      end

      private

      def update(&block)
        workspace.update_board(&block)
      end

      def workspace
        @workspace ||= Workspace.new
      end
    end
  end
end
