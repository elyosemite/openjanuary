require "thor"
require "tempfile"

module January
  class CLI < Thor
    class CardCommands < Thor
      def self.exit_on_failure?
        true
      end

      desc "add TITLE", "Add a card to the active project"
      option :column, aliases: "-c", desc: "Target column (defaults to the first one)"
      option :description, aliases: "-d", default: "", desc: "Card description"
      def add(title)
        card = update do |project|
          project.add_card(title, column: options[:column], description: options[:description])
        end
        puts "Added card ##{card.id} to '#{card.column}'."
      end

      desc "list", "List the cards of the active project"
      option :column, aliases: "-c", desc: "Only cards in this column"
      def list
        project = workspace.active_project
        cards = options[:column] ? project.cards_in(project_column(project, options[:column])) : project.cards
        return puts("No cards yet. Run 'january card add TITLE'.") if cards.empty?

        cards.each { |card| puts "##{card.id}  [#{card.column}]  #{card.title}" }
      end

      desc "show ID", "Show a card in full"
      def show(id)
        card = workspace.active_project.find_card(id)
        puts "##{card.id} #{card.title}"
        puts "Column: #{card.column}"
        puts
        puts card.description.empty? ? "(no description)" : card.description
      end

      desc "move ID COLUMN", "Move a card to another column"
      def move(id, column)
        card = update { |project| project.move_card(id, column) }
        puts "Moved card ##{card.id} to '#{card.column}'."
      end

desc "edit ID", "Edit a card (opens $EDITOR unless --title or --description is given)"
option :title, aliases: "-t", desc: "New title"
option :description, aliases: "-d", desc: "New description"
def edit(id)
  title, description = options[:title], options[:description]
  title, description = edit_in_editor(workspace.active_project.find_card(id)) if title.nil? && description.nil?
  card = update { |project| project.update_card(id, title: title, description: description) }
  puts "Updated card ##{card.id}."
end

desc "remove ID", "Delete a card"
      def remove(id)
        card = update { |project| project.remove_card(id) }
        puts "Removed card ##{card.id}."
      end

private

def edit_in_editor(card)
  Tempfile.create(["january-card-", ".md"]) do |file|
    file.write("#{card.title}\n\n#{card.description}\n")
    file.close
    editor = ENV["VISUAL"] || ENV["EDITOR"] || (Gem.win_platform? ? "notepad" : "vi")
    raise Error, "Editor #{editor} failed." unless system("#{editor} \"#{file.path}\"")

    title, *rest = File.read(file.path).lines
    [title.to_s, rest.join]
  end
end

      def project_column(project, name)
        project.columns.find { |c| c.casecmp?(name.strip) } || raise(Error, "Column '#{name.strip}' not found.")
      end

      def update(&block)
        workspace.update_project(workspace.active_project.name, &block)
      end

      def workspace
        @workspace ||= Workspace.new
      end
    end
  end
end
