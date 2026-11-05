require "test_helper"

class CliCardTest < Minitest::Test
  include TmpHome
  include CliHelper

  def setup
    super
    january("project", "add", "work")
    january("column", "add", "Backlog")
    january("column", "add", "Doing")
  end

  def test_add_uses_first_column_by_default
    assert_match(/Added card #1 to 'Backlog'/, january("card", "add", "Pay fee"))
  end

  def test_add_with_column_and_description
    january("card", "add", "Pay fee", "-c", "doing", "-d", "Due on the 10th")
    shown = january("card", "show", "1")
    assert_includes shown, "#1 Pay fee"
    assert_includes shown, "Column: Doing"
    assert_includes shown, "Due on the 10th"
  end

  def test_show_without_description
    january("card", "add", "A")
    assert_includes january("card", "show", "1"), "(no description)"
  end

  def test_list_all_and_by_column
    january("card", "add", "A")
    january("card", "add", "B", "-c", "Doing")
    assert_equal "#1  [Backlog]  A\n#2  [Doing]  B\n", january("card", "list")
    assert_equal "#2  [Doing]  B\n", january("card", "list", "-c", "doing")
  end

  def test_list_when_empty
    assert_match(/No cards yet/, january("card", "list"))
  end

  def test_list_unknown_column
    assert_match(/Column 'Nope' not found/, january("card", "list", "-c", "Nope"))
  end

  def test_move
    january("card", "add", "A")
    assert_match(/Moved card #1 to 'Doing'/, january("card", "move", "1", "doing"))
    assert_includes january("card", "list"), "[Doing]"
  end

  def test_remove
    january("card", "add", "A")
    assert_match(/Removed card #1/, january("card", "remove", "1"))
    assert_match(/No cards yet/, january("card", "list"))
  end

  def test_unknown_card
    assert_match(/january: Card #9 not found/, january("card", "show", "9"))
  end

  def test_add_without_columns_fails
    january("column", "remove", "Backlog")
    january("column", "remove", "Doing")
    assert_match(/Add a column first/, january("card", "add", "A"))
  end

  def test_column_remove_is_blocked_by_cards
    january("card", "add", "A")
    assert_match(/has 1 card/, january("column", "remove", "Backlog"))
  end

  def test_column_remove_move_to
    january("card", "add", "A")
    january("column", "remove", "Backlog", "--move-to", "Doing")
    assert_includes january("card", "list"), "[Doing]"
  end

  def test_column_remove_force
    january("card", "add", "A")
    january("column", "remove", "Backlog", "--force")
    assert_match(/No cards yet/, january("card", "list"))
  end
end
