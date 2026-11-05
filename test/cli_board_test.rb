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
end
