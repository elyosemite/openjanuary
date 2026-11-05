require "thor"

module January
  class CLI < Thor
    class ProjectCommands < Thor
      def self.exit_on_failure?
        true
      end

      desc "add NAME", "Create a project"
      def add(name)
        project = workspace.add_project(name)
        puts "Created project '#{project.name}'."
        puts "Now using '#{project.name}'." if workspace.active_name == project.name
      end

      desc "list", "List projects (* marks the active one)"
      def list
        names = workspace.project_names
        return puts("No projects yet. Run 'january project add NAME'.") if names.empty?

        names.each { |n| puts "#{n == workspace.active_name ? '*' : ' '} #{n}" }
      end

      desc "use NAME", "Switch the active project"
      def use(name)
        puts "Now using '#{workspace.use_project(name).name}'."
      end

      desc "remove NAME", "Delete a project and all its data"
      option :yes, type: :boolean, aliases: "-y", desc: "Skip the confirmation"
      def remove(name)
        project = workspace.find_project(name)
        unless options[:yes] || confirm?("Remove '#{project.name}' and all its data? (y/N) ")
          return puts("Aborted.")
        end

        workspace.remove_project(project.name)
        puts "Removed project '#{project.name}'."
      end

      private

      def confirm?(question)
        print question
        $stdout.flush
        $stdin.gets.to_s.strip.downcase.start_with?("y")
      end

      def workspace
        @workspace ||= Workspace.new
      end
    end
  end
end
