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
        columns = workspace.active_project.columns
        return puts("No columns yet. Run 'january column add NAME'.") if columns.empty?

        columns.each_with_index { |column, index| puts "#{index + 1}. #{column}" }
      end

      desc "remove NAME", "Remove a column from the active project"
      def remove(name)
        column = update { |project| project.remove_column(name) }
        puts "Removed column '#{column}'."
      end

      desc "move NAME --to POSITION", "Move a column to a 1-based position"
      option :to, type: :numeric, required: true, desc: "Target position, starting at 1"
      def move(name)
        column = update { |project| project.move_column(name, options[:to].to_i) }
        puts "Moved column '#{column}' to position #{options[:to].to_i}."
      end

      private

      def update(&block)
        workspace.update_project(workspace.active_project.name, &block)
      end

      def workspace
        @workspace ||= Workspace.new
      end
    end
  end
end
