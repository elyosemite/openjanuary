require "test_helper"

class EraTest < Minitest::Test
  D = Date.new(2026, 11, 1)

  def board
    @board ||= January::Board.new("main").tap do |p|
      %w[Backlog Doing Done].each { |c| p.add_column(c) }
    end
  end

  def test_start_era_sets_dates_and_becomes_current
    era = board.start_era("November", ends_on: Date.new(2026, 11, 30), today: D)
    assert_same era, board.current_era
    assert_equal [D, Date.new(2026, 11, 30)], [era.starts_on, era.ends_on]
  end

  def test_only_one_active_era
    board.start_era("A", today: D)
    error = assert_raises(January::Error) { board.start_era("B", today: D) }
    assert_match(/still active/, error.message)
  end

  def test_end_before_start_is_rejected
    assert_raises(January::Error) { board.start_era("A", ends_on: D - 1, today: D) }
  end

  def test_empty_name_is_rejected
    assert_raises(January::Error) { board.start_era(" ", today: D) }
  end

  def test_new_cards_join_the_current_era
    before = board.add_card("Before")
    era = board.start_era("A", today: D)
    inside = board.add_card("Inside")
    assert_nil before.era_id
    assert_equal era.id, inside.era_id
  end

  def test_board_cards_filters_by_era_unless_all
    board.add_card("Old")
    board.start_era("A", today: D)
    board.add_card("New")
    assert_equal ["New"], board.board_cards.map(&:title)
    assert_equal %w[Old New], board.board_cards(all: true).map(&:title)
  end

  def test_board_cards_without_era_shows_everything
    board.add_card("Old")
    assert_equal ["Old"], board.board_cards.map(&:title)
  end

  def test_close_without_active_era_fails
    assert_raises(January::Error) { board.close_era(today: D) }
  end

  def test_close_with_everything_done
    board.start_era("A", today: D)
    board.add_card("X", column: "Done")
    era = board.close_era(today: D + 5)
    assert_equal D + 5, era.closed_on
    assert_nil board.current_era
  end

  def test_close_requires_a_policy_for_unfinished_cards
    board.start_era("A", today: D)
    board.add_card("X")
    error = assert_raises(January::Error) { board.close_era(today: D) }
    assert_match(/--carry or --backlog/, error.message)
    assert board.current_era
  end

  def test_close_with_carry_moves_cards_to_next_era
    board.start_era("A", today: D)
    board.add_card("Pending", column: "Doing")
    done = board.add_card("Finished", column: "Done")
    first = board.current_era
    board.close_era(unfinished: :carry, today: D)
    second = board.start_era("B", today: D)
    assert_equal second.id, board.find_card(1).era_id
    assert_equal first.id, done.era_id
    assert_equal ["Pending"], board.board_cards.map(&:title)
  end

  def test_close_with_backlog_returns_cards_to_first_column
    board.start_era("A", today: D)
    board.add_card("Pending", column: "Doing")
    board.close_era(unfinished: :backlog, today: D)
    card = board.find_card(1)
    assert_equal ["Backlog", nil], [card.column, card.era_id]
    board.start_era("B", today: D)
    assert_empty board.board_cards
  end

  def test_removed_card_is_not_carried
    board.start_era("A", today: D)
    board.add_card("Pending")
    board.close_era(unfinished: :carry, today: D)
    board.remove_card(1)
    board.start_era("B", today: D)
    assert_empty board.cards
  end

  def test_roundtrip_through_hash
    board.start_era("A", ends_on: D + 29, today: D)
    board.add_card("Pending")
    board.close_era(unfinished: :carry, today: D + 10)
    copy = January::Board.from_h(YAML.safe_load(YAML.dump(board.to_h)))
    assert_equal D + 10, copy.eras.first.closed_on
    copy.start_era("B", today: D + 11)
    assert_equal copy.current_era.id, copy.find_card(1).era_id
    assert_equal 2, copy.current_era.id
  end

  def test_loads_legacy_hash_without_eras
    legacy = January::Board.from_h("name" => "old", "columns" => ["A"])
    assert_nil legacy.current_era
  end
end
