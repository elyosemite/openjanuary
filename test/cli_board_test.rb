require "test_helper"

class CliBoardTest < Minitest::Test
  include TmpHome
  include CliHelper

  def test_board_shows_project_columns_and_cards
    january("project", "add", "work")
    january("board", "column", "add", "Todo")
    january("board", "column", "add", "Done")
    january("board", "card", "add", "Write tests")
    january("board", "card", "add", "Ship", "-c", "Done")
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
    %w[Backlog Doing Done].each { |c| january("board", "column", "add", c) }
    assert_match(/Moved column 'Done' to position 1/, january("board", "move", "Done", "--to", "1"))
    assert_equal "1. Done\n2. Backlog\n3. Doing\n", january("board", "column", "list")
  end

  def test_move_requires_position
    january("project", "add", "work")
    january("board", "column", "add", "A")
    assert_match(/--to/, january("board", "move", "A"))
  end

  def test_move_out_of_range
    january("project", "add", "work")
    january("board", "column", "add", "A")
    assert_match(/Position must be between 1 and 1/, january("board", "move", "A", "--to", "5"))
  end

  def test_board_all_flag_still_works_without_subcommand
    january("project", "add", "work")
    january("board", "column", "add", "Todo")
    january("board", "card", "add", "Old")
    january("board", "era", "start", "A")
    refute_includes january("board"), "#1 Old"
    assert_includes january("board", "--all"), "#1 Old"
  end

  def test_column_no_longer_moves
    january("project", "add", "work")
    january("board", "column", "add", "A")
    refute_match(/column move/, january("board", "column", "help"))
  end

  def test_new_project_starts_with_main_board
    january("project", "add", "work")
    assert_equal "* main\n", january("board", "list")
    assert_includes january("board"), "Board: main"
  end

  def test_add_list_and_use
    january("project", "add", "work")
    assert_match(/Created board 'studies'/, january("board", "add", "studies"))
    assert_equal "* main\n  studies\n", january("board", "list")
    assert_match(/Now using board 'studies'/, january("board", "use", "studies"))
    assert_equal "  main\n* studies\n", january("board", "list")
  end

  def test_boards_keep_separate_columns_cards_and_eras
    january("project", "add", "work")
    january("board", "column", "add", "Todo")
    january("board", "card", "add", "On main")
    january("board", "add", "studies")
    january("board", "use", "studies")
    assert_match(/No columns yet/, january("board", "column", "list"))
    january("board", "column", "add", "Reading")
    january("board", "era", "start", "Semester")
    january("board", "card", "add", "Chapter 1")
    assert_includes january("board"), "Board: studies"
    assert_includes january("board"), "#1 Chapter 1"
    refute_includes january("board"), "On main"
    january("board", "use", "main")
    assert_includes january("board"), "#1 On main"
    assert_match(/No active era/, january("board", "era", "current"))
  end

  def test_each_project_remembers_its_own_active_board
    january("project", "add", "a")
    january("board", "add", "x")
    january("board", "use", "x")
    january("project", "add", "b")
    january("project", "use", "b")
    assert_equal "* main\n", january("board", "list")
    january("project", "use", "a")
    assert_equal "  main\n* x\n", january("board", "list")
  end

  def test_use_unknown_board
    january("project", "add", "work")
    assert_match(/Board 'nope' not found/, january("board", "use", "nope"))
  end

  def test_duplicate_board
    january("project", "add", "work")
    assert_match(/already exists/, january("board", "add", "main"))
  end

  def test_remove_board_with_confirmation
    january("project", "add", "work")
    january("board", "add", "studies")
    assert_match(/Aborted/, january("board", "remove", "studies", input: "n\n"))
    assert_match(/Removed board 'studies'/, january("board", "remove", "studies", "--yes"))
    assert_equal "* main\n", january("board", "list")
  end

  def test_cannot_remove_the_last_board
    january("project", "add", "work")
    assert_match(/at least one board/, january("board", "remove", "main", "--yes"))
  end

  def test_removing_active_board_falls_back
    january("project", "add", "work")
    january("board", "add", "studies")
    january("board", "use", "studies")
    january("board", "remove", "studies", "-y")
    assert_equal "* main\n", january("board", "list")
  end

  def test_column_and_card_are_only_reachable_through_board
    january("project", "add", "work")
    assert_match(/Could not find command "column"/, january("column", "list"))
    assert_match(/Could not find command "card"/, january("card", "list"))
  end
end
