require "test_helper"

class CardTest < Minitest::Test
  def board
    @board ||= January::Board.new("main").tap do |p|
      p.add_column("Backlog")
      p.add_column("Doing")
    end
  end

  def test_add_card_defaults_to_first_column_and_sequential_ids
    a = board.add_card("First")
    b = board.add_card("Second", description: "  details ")
    assert_equal [1, 2], [a.id, b.id]
    assert_equal "Backlog", a.column
    assert_equal "details", b.description
  end

  def test_add_card_into_named_column_ignoring_case
    assert_equal "Doing", board.add_card("X", column: "doing").column
  end

  def test_add_card_without_columns_fails
    assert_raises(January::Error) { January::Board.new("empty").add_card("X") }
  end

  def test_add_card_to_unknown_column_fails
    assert_raises(January::Error) { board.add_card("X", column: "Nope") }
  end

  def test_empty_title_is_rejected
    assert_raises(January::Error) { board.add_card("  ") }
  end

  def test_ids_are_not_reused_after_removal
    board.add_card("A")
    board.add_card("B")
    board.remove_card(2)
    assert_equal 3, board.add_card("C").id
  end

  def test_find_unknown_card_fails
    assert_raises(January::Error) { board.find_card(99) }
  end

  def test_move_card
    board.add_card("A")
    board.move_card(1, "doing")
    assert_equal "Doing", board.find_card(1).column
    assert_raises(January::Error) { board.move_card(1, "Nope") }
  end

  def test_update_card_changes_only_given_fields
    board.add_card("Old", description: "keep")
    board.update_card(1, title: "New")
    assert_equal ["New", "keep"], [board.find_card(1).title, board.find_card(1).description]
    board.update_card(1, description: "")
    assert_equal "", board.find_card(1).description
  end

  def test_update_card_rejects_empty_title
    board.add_card("A")
    assert_raises(January::Error) { board.update_card(1, title: " ") }
  end

  def test_cards_in_column
    board.add_card("A")
    board.add_card("B", column: "Doing")
    assert_equal ["B"], board.cards_in("Doing").map(&:title)
  end

  def test_roundtrip_keeps_cards_and_next_id
    board.add_card("A", description: "d")
    board.add_card("B")
    board.remove_card(2)
    copy = January::Board.from_h(board.to_h)
    assert_equal ["A"], copy.cards.map(&:title)
    assert_equal 3, copy.add_card("C").id
  end

  def test_remove_column_with_cards_is_blocked
    board.add_card("A")
    error = assert_raises(January::Error) { board.remove_column("Backlog") }
    assert_match(/--move-to/, error.message)
    assert_equal %w[Backlog Doing], board.columns
    assert_equal 1, board.cards.size
  end

  def test_remove_column_moving_cards
    board.add_card("A")
    board.remove_column("Backlog", move_to: "Doing")
    assert_equal "Doing", board.find_card(1).column
    assert_equal %w[Doing], board.columns
  end

  def test_remove_column_move_to_itself_fails
    board.add_card("A")
    assert_raises(January::Error) { board.remove_column("Backlog", move_to: "backlog") }
    assert_equal %w[Backlog Doing], board.columns
  end

  def test_remove_column_with_force_deletes_cards
    board.add_card("A")
    board.add_card("B", column: "Doing")
    board.remove_column("Backlog", force: true)
    assert_equal ["B"], board.cards.map(&:title)
  end
end
