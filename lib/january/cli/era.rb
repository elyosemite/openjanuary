require "thor"

module January
  class CLI < Thor
    class EraCommands < Thor
      def self.exit_on_failure?
        true
      end

      desc "start NAME", "Start a new era in the active project"
      option :ends, desc: "Planned end date (YYYY-MM-DD)"
      def start(name)
        ends_on = Era.parse(options[:ends])
        era = update { |project| project.start_era(name, ends_on: ends_on) }
        adopted = workspace.active_board.cards_in_era(era).size
        puts "Started era '#{era.name}'."
        puts "#{adopted} carried card(s) joined it." if adopted.positive?
      end

      desc "current", "Show the active era"
      def current
        project = workspace.active_board
        era = project.current_era
        return puts("No active era. Run 'january era start NAME'.") unless era

        cards = project.cards_in_era(era)
        puts "Era: #{era.name}"
        puts "Started: #{era.starts_on}"
        puts "Ends: #{era.ends_on || 'not set'}"
        puts "Cards: #{cards.size} (#{project.unfinished_cards(era).size} unfinished)"
      end

      desc "close", "Close the active era"
      option :carry, type: :boolean, desc: "Carry unfinished cards to the next era"
      option :backlog, type: :boolean, desc: "Send unfinished cards back to the first column"
      def close
        project = workspace.active_board
        era = project.current_era or raise Error, "No active era."
        total = project.cards_in_era(era).size
        unfinished = project.unfinished_cards(era).size
        policy = unfinished.zero? ? nil : unfinished_policy(unfinished)

        update { |p| p.close_era(unfinished: policy) }
        puts "Closed era '#{era.name}': #{total} card(s), #{total - unfinished} done, #{unfinished} unfinished."
        puts "Unfinished cards will join the next era." if policy == :carry
        puts "Unfinished cards went back to the first column." if policy == :backlog
      end

      private

      def unfinished_policy(count)
        raise Error, "Choose only one of --carry or --backlog." if options[:carry] && options[:backlog]
        return :carry if options[:carry]
        return :backlog if options[:backlog]

        print "#{count} unfinished card(s). Carry to the next era (c) or send to backlog (b)? [c/b] "
        $stdout.flush
        answer = $stdin.gets.to_s.strip.downcase
        return :carry if answer.start_with?("c")
        return :backlog if answer.start_with?("b")

        raise Error, "Aborted. Nothing was changed."
      end

      def update(&block)
        workspace.update_board(&block)
      end

      def workspace
        @workspace ||= Workspace.new
      end
    end
  end
end
