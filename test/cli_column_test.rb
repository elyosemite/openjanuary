require "test_helper"

class CliColumnTest < Minitest::Test
  include TmpHome
  include CliHelper

  def setup
    super
    january("project", "add", "work")
  end

  def test_add_and_list_in_order
    assert_match(/Added column 'Backlog'/, january("column", "add", "Backlog"))
    january("column", "add", "Doing")
    january("column", "add", "Done")
    assert_equal "1. Backlog\n2. Doing\n3. Done\n", january("column", "list")
  end

  def test_list_when_empty
    assert_match(/No columns yet/, january("column", "list"))
  end

  def test_remove
    january("column", "add", "Backlog")
    assert_match(/Removed column 'Backlog'/, january("column", "remove", "backlog"))
    assert_match(/No columns yet/, january("column", "list"))
  end

  def test_duplicate_reports_error
    january("column", "add", "Backlog")
    assert_match(/january: Column 'Backlog' already exists/, january("column", "add", "backlog"))
  end

  def test_columns_are_per_project
    january("column", "add", "Backlog")
    january("project", "add", "finances")
    january("project", "use", "finances")
    assert_match(/No columns yet/, january("column", "list"))
    january("project", "use", "work")
    assert_equal "1. Backlog\n", january("column", "list")
  end

  def test_requires_active_project
    january("project", "remove", "work", "--yes")
    assert_match(/No active project/, january("column", "list"))
  end
end
