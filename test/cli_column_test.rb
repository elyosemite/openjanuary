require "test_helper"

class CliColumnTest < Minitest::Test
  include TmpHome
  include CliHelper

  def setup
    super
    january("project", "add", "work")
  end

def test_new_board_has_default_columns
  assert_equal "1. Backlog\n2. Doing\n3. Done\n", january("board", "column", "list")
end

def test_add_appends_at_the_end
  assert_match(/Added column 'Review'/, january("board", "column", "add", "Review"))
  assert_equal "1. Backlog\n2. Doing\n3. Done\n4. Review\n", january("board", "column", "list")
end

def test_remove
  assert_match(/Removed column 'Backlog'/, january("board", "column", "remove", "backlog"))
  assert_equal "1. Doing\n2. Done\n", january("board", "column", "list")
end

def test_removing_every_column_leaves_an_empty_board
  %w[Backlog Doing Done].each { |c| january("board", "column", "remove", c) }
  assert_match(/No columns yet/, january("board", "column", "list"))
end

def test_duplicate_reports_error
  assert_match(/january: Column 'Backlog' already exists/, january("board", "column", "add", "backlog"))
end

def test_columns_are_per_project
  january("board", "column", "add", "Extra")
  january("project", "add", "finances")
  january("project", "use", "finances")
  assert_equal "1. Backlog\n2. Doing\n3. Done\n", january("board", "column", "list")
  january("project", "use", "work")
  assert_includes january("board", "column", "list"), "4. Extra"
end

  def test_requires_active_project
    january("project", "remove", "work", "--yes")
    assert_match(/No active project/, january("board", "column", "list"))
  end
end
