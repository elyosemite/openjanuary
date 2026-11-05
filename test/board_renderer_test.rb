require "test_helper"

class BoardRendererTest < Minitest::Test
  Card = Struct.new(:id, :title, :column)

  def render(columns, cards, width: 80)
    January::BoardRenderer.new(columns: columns, cards: cards, width: width).render
  end

  def test_no_columns
    assert_match(/No columns yet/, render([], []))
  end

  def test_side_by_side_layout
    cards = [Card.new(1, "Alpha", "Todo"), Card.new(2, "Beta", "Todo"), Card.new(3, "Gamma", "Done")]
    lines = render(%w[Todo Done], cards, width: 40).lines.map(&:chomp)
    assert_match(/\ATodo \(2\) +Done \(1\)\z/, lines[0])
    assert_match(/\A-+ +-+\z/, lines[1])
    assert_match(/\A#1 Alpha +#3 Gamma\z/, lines[2])
    assert_equal "#2 Beta", lines[3]
  end

  def test_empty_column_still_shows_header
    out = render(%w[Todo Done], [Card.new(1, "A", "Todo")], width: 40)
    assert_includes out, "Done (0)"
  end

  def test_long_titles_are_truncated_to_column_width
    long = Card.new(1, "x" * 100, "Todo")
    out = render(%w[Todo Done], [long], width: 40)
    assert out.lines.all? { |l| l.chomp.size <= 40 }
    assert_includes out, "..."
  end

  def test_narrow_terminal_stacks_columns
    cards = [Card.new(1, "Alpha", "Todo"), Card.new(2, "Beta", "Done")]
    out = render(%w[Todo Done], cards, width: 20)
    assert_equal "Todo (1)\n  #1 Alpha\n\nDone (1)\n  #2 Beta", out
  end

  def test_stacked_truncates_long_titles
    out = render(%w[A B C], [Card.new(1, "y" * 50, "A")], width: 20)
    assert out.lines.all? { |l| l.chomp.size <= 20 }
  end
end
