module January
  class BoardRenderer
    SEPARATOR = "   ".freeze
    MIN_COLUMN_WIDTH = 16
    ELLIPSIS = "...".freeze

    def initialize(columns:, cards:, width: 80)
      @columns = columns
      @cards = cards
      @width = width
    end

    def render
      return "No columns yet. Run 'january board column add NAME'." if @columns.empty?

      side_by_side? ? render_side_by_side : render_stacked
    end

    private

    def side_by_side?
      column_width >= MIN_COLUMN_WIDTH
    end

    def column_width
      (@width - SEPARATOR.size * (@columns.size - 1)) / @columns.size
    end

    def cards_in(column)
      @cards.select { |card| card.column == column }
    end

    def label(card)
      "##{card.id} #{card.title}"
    end

    def fit(text, width)
      return text.ljust(width) if text.size <= width

      text[0, width - ELLIPSIS.size] + ELLIPSIS
    end

    def render_side_by_side
      width = column_width
      groups = @columns.map { |column| cards_in(column) }
      headers = @columns.each_with_index.map { |column, i| fit("#{column} (#{groups[i].size})", width) }
      rules = Array.new(@columns.size) { "-" * width }
      rows = (0...(groups.map(&:size).max)).map do |row|
        groups.map { |cards| fit(cards[row] ? label(cards[row]) : "", width) }
      end

      ([headers, rules] + rows).map { |cells| cells.join(SEPARATOR).rstrip }.join("\n")
    end

    def render_stacked
      @columns.map do |column|
        cards = cards_in(column)
        lines = cards.map { |card| "  #{fit(label(card), @width - 2).rstrip}" }
        ["#{column} (#{cards.size})", *lines].join("\n")
      end.join("\n\n")
    end
  end
end
