module January
  class Project
    NAME_FORMAT = /\A[a-z0-9][a-z0-9_-]*\z/

    attr_reader :name, :columns, :cards

    def self.normalize(name)
      name.to_s.strip.downcase
    end

    def self.from_h(hash)
      new(
        hash.fetch("name"),
        columns: hash.fetch("columns", []),
        cards: hash.fetch("cards", []).map { |c| Card.from_h(c) },
        next_card_id: hash["next_card_id"]
      )
    end

    def initialize(name, columns: [], cards: [], next_card_id: nil)
      @name = self.class.normalize(name)
      @columns = columns.dup
      @cards = cards.dup
      @next_card_id = next_card_id || ((@cards.map(&:id).max || 0) + 1)
      return if @name.match?(NAME_FORMAT)

      raise Error, "Invalid project name '#{name}'. Use letters, digits, '-' or '_'."
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

      card = Card.new(id: @next_card_id, title: title, description: description, column: target)
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
      card
    end

    def to_h
      {
        "name" => name,
        "columns" => columns,
        "cards" => cards.map(&:to_h),
        "next_card_id" => @next_card_id
      }
    end

    private

    def handle_cards_of_removed_column(column, affected, force, move_to)
      if move_to
        target = fetch_column(move_to)
        raise Error, "Cannot move cards into the column being removed." if target == column

        affected.each { |card| card.column = target }
      elsif force
        @cards -= affected
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
