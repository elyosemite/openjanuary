module January
  class Board
    attr_reader :name, :columns, :cards, :eras

    def self.from_h(hash)
      new(
        hash.fetch("name"),
        columns: hash.fetch("columns", []),
        cards: hash.fetch("cards", []).map { |c| Card.from_h(c) },
        next_card_id: hash["next_card_id"],
        eras: hash.fetch("eras", []).map { |e| Era.from_h(e) },
        next_era_id: hash["next_era_id"],
        carry_ids: hash.fetch("carry_ids", [])
      )
    end

    def initialize(name, columns: [], cards: [], next_card_id: nil, eras: [], next_era_id: nil, carry_ids: [])
      @name = Naming.validate!(name, "board")
      @columns = columns.dup
      @cards = cards.dup
      @next_card_id = next_card_id || ((@cards.map(&:id).max || 0) + 1)
      @eras = eras.dup
      @next_era_id = next_era_id || ((@eras.map(&:id).max || 0) + 1)
      @carry_ids = carry_ids.dup
    end

    def add_column(name)
      name = name.to_s.strip
      raise Error, "Column name cannot be empty." if name.empty?
      raise Error, "Column '#{find_column(name)}' already exists." if find_column(name)

      @columns << name
      name
    end

    def remove_column(name, force: false, move_to: nil)
      column = fetch_column(name)
      affected = cards_in(column)
      handle_cards_of_removed_column(column, affected, force, move_to) unless affected.empty?
      @columns.delete(column)
      column
    end

    def move_column(name, position)
      column = fetch_column(name)
      unless position.between?(1, @columns.size)
        raise Error, "Position must be between 1 and #{@columns.size}."
      end

      @columns.delete(column)
      @columns.insert(position - 1, column)
      column
    end

    def add_card(title, column: nil, description: "")
      target = column ? fetch_column(column) : @columns.first
      raise Error, "Add a column first with 'january column add NAME'." unless target

      card = Card.new(
        id: @next_card_id, title: title, description: description, column: target, era_id: current_era&.id
      )
      @next_card_id += 1
      @cards << card
      card
    end

    def find_card(id)
      @cards.find { |c| c.id == id.to_i } || raise(Error, "Card ##{id} not found.")
    end

    def cards_in(column)
      @cards.select { |c| c.column.casecmp?(column) }
    end

    def move_card(id, column)
      card = find_card(id)
      card.column = fetch_column(column)
      card
    end

    def update_card(id, title: nil, description: nil)
      card = find_card(id)
      card.title = title unless title.nil?
      card.description = description unless description.nil?
      card
    end

    def remove_card(id)
      card = find_card(id)
      @cards.delete(card)
      @carry_ids.delete(card.id)
      card
    end

    def current_era
      @eras.find(&:active?)
    end

    def start_era(name, ends_on: nil, today: Date.today)
      if current_era
        raise Error, "Era '#{current_era.name}' is still active. Close it with 'january era close'."
      end

      era = Era.new(id: @next_era_id, name: name, starts_on: today, ends_on: ends_on)
      @next_era_id += 1
      @eras << era
      @cards.select { |card| @carry_ids.include?(card.id) }.each { |card| card.era_id = era.id }
      @carry_ids = []
      era
    end

    def cards_in_era(era)
      @cards.select { |card| card.era_id == era.id }
    end

    def unfinished_cards(era)
      done = @columns.last
      cards_in_era(era).reject { |card| card.column == done }
    end

    def close_era(unfinished: nil, today: Date.today)
      era = current_era or raise Error, "No active era."
      pending = unfinished_cards(era)
      apply_unfinished_policy(pending, unfinished) unless pending.empty?
      era.close(today)
      era
    end

    def board_cards(all: false)
      era = current_era
      all || era.nil? ? @cards : cards_in_era(era)
    end

    def to_h
      {
        "name" => name,
        "columns" => columns,
        "cards" => cards.map(&:to_h),
        "next_card_id" => @next_card_id,
        "eras" => eras.map(&:to_h),
        "next_era_id" => @next_era_id,
        "carry_ids" => @carry_ids
      }
    end

    private

    def apply_unfinished_policy(pending, policy)
      case policy
      when :carry
        pending.each do |card|
          card.era_id = nil
          @carry_ids << card.id
        end
      when :backlog
        pending.each do |card|
          card.era_id = nil
          card.column = @columns.first
        end
      else
        raise Error, "The era has #{pending.size} unfinished card(s). Choose --carry or --backlog."
      end
    end

    def handle_cards_of_removed_column(column, affected, force, move_to)
      if move_to
        target = fetch_column(move_to)
        raise Error, "Cannot move cards into the column being removed." if target == column

        affected.each { |card| card.column = target }
      elsif force
        @cards -= affected
        @carry_ids -= affected.map(&:id)
      else
        raise Error, "Column '#{column}' has #{affected.size} card(s). Use --move-to COLUMN or --force."
      end
    end

    def find_column(name)
      @columns.find { |c| c.casecmp?(name.to_s.strip) }
    end

    def fetch_column(name)
      find_column(name) || raise(Error, "Column '#{name.to_s.strip}' not found.")
    end
  end
end
