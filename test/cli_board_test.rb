require "test_helper"

class CliBoardTest < Minitest::Test
  include TmpHome
  include CliHelper

  def test_board_shows_project_columns_and_cards
    january("project", "add", "work")
    january("column", "add", "Todo")
    january("column", "add", "Done")
    january("card", "add", "Write tests")
    january("card", "add", "Ship", "-c", "Done")
    ENV["COLUMNS"] = "60"
    out = january("board")
    assert_includes out, "Project: work"
    assert_match(/Todo \(1\) +Done \(1\)/, out)
    assert_match(/#1 Write tests +#2 Ship/, out)
  ensure
    ENV.delete("COLUMNS")
  end

  def test_board_requires_active_project
    assert_match(/No active project/, january("board"))
  end

  def test_move_column
    january("project", "add", "work")
    %w[Backlog Doing Done].each { |c| january("column", "add", c) }
    assert_match(/Moved column 'Done' to position 1/, january("board", "move", "Done", "--to", "1"))
    assert_equal "1. Done\n2. Backlog\n3. Doing\n", january("column", "list")
  end

  def test_move_requires_position
    january("project", "add", "work")
    january("column", "add", "A")
    assert_match(/--to/, january("board", "move", "A"))
  end

  def test_move_out_of_range
    january("project", "add", "work")
    january("column", "add", "A")
    assert_match(/Position must be between 1 and 1/, january("board", "move", "A", "--to", "5"))
  end

  def test_board_all_flag_still_works_without_subcommand
    january("project", "add", "work")
    january("column", "add", "Todo")
    january("card", "add", "Old")
    january("era", "start", "A")
    refute_includes january("board"), "#1 Old"
    assert_includes january("board", "--all"), "#1 Old"
  end

  def test_column_no_longer_moves
    january("project", "add", "work")
    january("column", "add", "A")
    refute_match(/column move/, january("column", "help"))
  end
end
