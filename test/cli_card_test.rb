require "test_helper"

class CliCardTest < Minitest::Test
  include TmpHome
  include CliHelper

  def setup
    super
    january("project", "add", "work")
    january("board", "column", "add", "Backlog")
    january("board", "column", "add", "Doing")
  end

  def test_add_uses_first_column_by_default
    assert_match(/Added card #1 to 'Backlog'/, january("board", "card", "add", "Pay fee"))
  end

  def test_add_with_column_and_description
    january("board", "card", "add", "Pay fee", "-c", "doing", "-d", "Due on the 10th")
    shown = january("board", "card", "show", "1")
    assert_includes shown, "#1 Pay fee"
    assert_includes shown, "Column: Doing"
    assert_includes shown, "Due on the 10th"
  end

  def test_show_without_description
    january("board", "card", "add", "A")
    assert_includes january("board", "card", "show", "1"), "(no description)"
  end

  def test_list_all_and_by_column
    january("board", "card", "add", "A")
    january("board", "card", "add", "B", "-c", "Doing")
    assert_equal "#1  [Backlog]  A\n#2  [Doing]  B\n", january("board", "card", "list")
    assert_equal "#2  [Doing]  B\n", january("board", "card", "list", "-c", "doing")
  end

  def test_list_when_empty
    assert_match(/No cards yet/, january("board", "card", "list"))
  end

  def test_list_unknown_column
    assert_match(/Column 'Nope' not found/, january("board", "card", "list", "-c", "Nope"))
  end

  def test_move
    january("board", "card", "add", "A")
    assert_match(/Moved card #1 to 'Doing'/, january("board", "card", "move", "1", "doing"))
    assert_includes january("board", "card", "list"), "[Doing]"
  end

  def test_remove
    january("board", "card", "add", "A")
    assert_match(/Removed card #1/, january("board", "card", "remove", "1"))
    assert_match(/No cards yet/, january("board", "card", "list"))
  end

  def test_unknown_card
    assert_match(/january: Card #9 not found/, january("board", "card", "show", "9"))
  end

  def test_add_without_columns_fails
    january("board", "column", "remove", "Backlog")
    january("board", "column", "remove", "Doing")
    assert_match(/Add a column first/, january("board", "card", "add", "A"))
  end

  def test_column_remove_is_blocked_by_cards
    january("board", "card", "add", "A")
    assert_match(/has 1 card/, january("board", "column", "remove", "Backlog"))
  end

  def test_column_remove_move_to
    january("board", "card", "add", "A")
    january("board", "column", "remove", "Backlog", "--move-to", "Doing")
    assert_includes january("board", "card", "list"), "[Doing]"
  end

  def test_column_remove_force
    january("board", "card", "add", "A")
    january("board", "column", "remove", "Backlog", "--force")
    assert_match(/No cards yet/, january("board", "card", "list"))
  end

  def test_edit_with_flags
    january("board", "card", "add", "Old", "-d", "keep")
    assert_match(/Updated card #1/, january("board", "card", "edit", "1", "--title", "New"))
    shown = january("board", "card", "show", "1")
    assert_includes shown, "#1 New"
    assert_includes shown, "keep"
  end

  def test_edit_description_only
    january("board", "card", "add", "A")
    january("board", "card", "edit", "1", "-d", "Fresh")
    assert_includes january("board", "card", "show", "1"), "Fresh"
  end

  def test_edit_rejects_empty_title
    january("board", "card", "add", "A")
    assert_match(/title cannot be empty/, january("board", "card", "edit", "1", "-t", " "))
  end

  def test_edit_opens_editor
    script = File.join(@home, "fake_editor.rb")
    File.write(script, "File.write(ARGV[0], \"Edited title\n\nEdited body\n\")\n")
    january("board", "card", "add", "Original")
    old = ENV["EDITOR"]
    ENV["EDITOR"] = "ruby #{script}"
    ENV.delete("VISUAL")
    january("board", "card", "edit", "1")
    shown = january("board", "card", "show", "1")
    assert_includes shown, "#1 Edited title"
    assert_includes shown, "Edited body"
  ensure
    old ? ENV["EDITOR"] = old : ENV.delete("EDITOR")
  end

  def test_edit_unknown_card
    assert_match(/Card #9 not found/, january("board", "card", "edit", "9", "-t", "x"))
  end
end
