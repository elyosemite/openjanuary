require "test_helper"

class CliBoardOptionTest < Minitest::Test
  include TmpHome
  include CliHelper

  def setup
    super
    ENV["COLUMNS"] = "80"
    january("project", "add", "work")
    january("board", "add", "studies")
  end

  def teardown
    ENV.delete("COLUMNS")
    super
  end

  def test_column_commands_target_a_named_board_without_switching
    january("board", "column", "add", "Reading", "--board", "studies")
    assert_equal "1. Backlog\n2. Doing\n3. Done\n4. Reading\n", january("board", "column", "list", "-b", "studies")
    assert_equal "1. Backlog\n2. Doing\n3. Done\n", january("board", "column", "list")
    assert_includes january("board", "list"), "* main"
  end

  def test_card_commands_target_a_named_board
    assert_match(/Added card #1 to 'Backlog'/, january("board", "card", "add", "Chapter 1", "-b", "studies"))
    assert_match(/No cards yet/, january("board", "card", "list"))
    assert_includes january("board", "card", "list", "-b", "studies"), "Chapter 1"
    assert_includes january("board", "card", "show", "1", "-b", "studies"), "#1 Chapter 1"
    january("board", "card", "move", "1", "Doing", "-b", "studies")
    january("board", "card", "edit", "1", "-t", "Renamed", "-b", "studies")
    assert_includes january("board", "card", "list", "-b", "studies"), "Renamed"
    january("board", "card", "remove", "1", "-b", "studies")
    assert_match(/No cards yet/, january("board", "card", "list", "-b", "studies"))
  end

  def test_card_ids_are_independent_per_board
    january("board", "card", "add", "On main")
    assert_match(/card #1/, january("board", "card", "add", "On studies", "-b", "studies"))
  end

  def test_era_commands_target_a_named_board
    january("board", "era", "start", "Semester", "-b", "studies")
    assert_includes january("board", "era", "current", "-b", "studies"), "Era: Semester"
    assert_match(/No active era/, january("board", "era", "current"))
    assert_match(/Closed era 'Semester'/, january("board", "era", "close", "-b", "studies"))
  end

  def test_move_column_on_a_named_board
    january("board", "column", "add", "A", "-b", "studies")
    january("board", "column", "add", "B", "-b", "studies")
    january("board", "move", "B", "--to", "1", "--board", "studies")
    assert_equal "1. B\n2. Backlog\n3. Doing\n4. Done\n5. A\n", january("board", "column", "list", "-b", "studies")
  end

  def test_unknown_board
    assert_match(/Board 'nope' not found/, january("board", "column", "list", "--board", "nope"))
    assert_match(/Board 'nope' not found/, january("board", "card", "add", "X", "-b", "nope"))
  end

  def test_board_name_is_case_insensitive
    january("board", "column", "add", "Reading", "-b", "STUDIES")
    assert_includes january("board", "column", "list", "-b", "studies"), "4. Reading"
  end

  def test_era_is_only_reachable_through_board
    assert_match(/Could not find command "era"/, january("era", "current"))
  end
end
