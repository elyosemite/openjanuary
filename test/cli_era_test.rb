require "test_helper"

class CliEraTest < Minitest::Test
  include TmpHome
  include CliHelper

  def setup
    super
    january("project", "add", "work")
    %w[Backlog Doing Done].each { |c| january("board", "column", "add", c) }
  end

  def test_current_without_era
    assert_match(/No active era/, january("board", "era", "current"))
  end

  def test_start_and_current
    assert_match(/Started era 'November'/, january("board", "era", "start", "November", "--ends", "2099-11-30"))
    out = january("board", "era", "current")
    assert_includes out, "Era: November"
    assert_includes out, "Ends: 2099-11-30"
    assert_includes out, "Cards: 0 (0 unfinished)"
  end

  def test_start_with_invalid_date
    assert_match(/Invalid date/, january("board", "era", "start", "N", "--ends", "tomorrow"))
  end

  def test_second_start_is_rejected
    january("board", "era", "start", "A")
    assert_match(/still active/, january("board", "era", "start", "B"))
  end

  def test_close_all_done
    january("board", "era", "start", "A")
    january("board", "card", "add", "X", "-c", "Done")
    assert_match(/Closed era 'A': 1 card\(s\), 1 done, 0 unfinished/, january("board", "era", "close"))
    assert_match(/No active era/, january("board", "era", "current"))
  end

  def test_close_without_era
    assert_match(/No active era/, january("board", "era", "close"))
  end

  def test_close_with_carry_flag_and_next_era_adopts
    january("board", "era", "start", "A")
    january("board", "card", "add", "Pending")
    assert_match(/will join the next era/, january("board", "era", "close", "--carry"))
    assert_match(/1 carried card\(s\) joined it/, january("board", "era", "start", "B"))
    assert_includes january("board"), "#1 Pending"
  end

  def test_close_with_backlog_flag
    january("board", "era", "start", "A")
    january("board", "card", "add", "Pending", "-c", "Doing")
    january("board", "era", "close", "--backlog")
    assert_includes january("board", "card", "list"), "[Backlog]"
  end

  def test_close_prompts_for_policy
    january("board", "era", "start", "A")
    january("board", "card", "add", "Pending")
    out = january("board", "era", "close", input: "b\n")
    assert_includes out, "unfinished card(s)"
    assert_includes out, "went back to the first column"
  end

  def test_close_with_unrecognized_answer_changes_nothing
    january("board", "era", "start", "A")
    january("board", "card", "add", "Pending")
    assert_match(/Aborted/, january("board", "era", "close", input: "x\n"))
    assert_includes january("board", "era", "current"), "Era: A"
  end

  def test_close_rejects_both_flags
    january("board", "era", "start", "A")
    january("board", "card", "add", "Pending")
    assert_match(/only one/, january("board", "era", "close", "--carry", "--backlog"))
  end

  def test_board_filters_by_era_and_all_flag
    january("board", "card", "add", "Old")
    january("board", "era", "start", "A")
    january("board", "card", "add", "New")
    filtered = january("board")
    assert_includes filtered, "Era: A"
    assert_includes filtered, "#2 New"
    refute_includes filtered, "#1 Old"
    assert_includes january("board", "--all"), "#1 Old"
  end
end
