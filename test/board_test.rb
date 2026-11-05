require "test_helper"

class BoardTest < Minitest::Test
  def board
    @board ||= January::Board.new("main")
  end

  def test_starts_without_columns
    assert_equal [], board.columns
  end

  def test_add_column_keeps_order_and_case
    board.add_column("Backlog")
    board.add_column("  Doing ")
    assert_equal %w[Backlog Doing], board.columns
  end

  def test_duplicate_column_is_rejected_ignoring_case
    board.add_column("Backlog")
    error = assert_raises(January::Error) { board.add_column("backlog") }
    assert_match(/already exists/, error.message)
  end

  def test_empty_column_is_rejected
    assert_raises(January::Error) { board.add_column("   ") }
  end

  def test_remove_column_ignores_case
    board.add_column("Backlog")
    board.add_column("Done")
    assert_equal "Backlog", board.remove_column("BACKLOG")
    assert_equal %w[Done], board.columns
  end

  def test_remove_unknown_column_fails
    assert_raises(January::Error) { board.remove_column("Nope") }
  end

  def test_move_column_to_front_middle_and_end
    %w[A B C D].each { |c| board.add_column(c) }
    board.move_column("D", 1)
    assert_equal %w[D A B C], board.columns
    board.move_column("A", 3)
    assert_equal %w[D B A C], board.columns
    board.move_column("D", 4)
    assert_equal %w[B A C D], board.columns
  end

  def test_move_rejects_out_of_range_position
    board.add_column("A")
    assert_raises(January::Error) { board.move_column("A", 0) }
    assert_raises(January::Error) { board.move_column("A", 2) }
  end

  def test_move_unknown_column_fails
    assert_raises(January::Error) { board.move_column("Nope", 1) }
  end

  def test_roundtrip_through_hash
    board.add_column("Backlog")
    copy = January::Board.from_h(board.to_h)
    assert_equal %w[Backlog], copy.columns
  end

  def test_loads_legacy_hash_without_columns
    assert_equal [], January::Board.from_h("name" => "old").columns
  end

  def test_columns_are_not_shared_with_caller_array
    source = %w[A]
    January::Board.new("x", columns: source).add_column("B")
    assert_equal %w[A], source
  end
end
