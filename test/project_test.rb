require "test_helper"

class ProjectTest < Minitest::Test
  def project
    @project ||= January::Project.new("work")
  end

  def test_new_project_has_a_default_board
    assert_equal %w[main], project.board_names
    assert_equal "main", project.active_board.name
  end

  def test_add_board_and_normalize_name
    project.add_board(" Side-Quests ")
    assert_equal %w[main side-quests], project.board_names
  end

  def test_duplicate_board_is_rejected
    assert_raises(January::Error) { project.add_board("MAIN") }
  end

  def test_invalid_board_name_is_rejected
    assert_raises(January::Error) { project.add_board("a b") }
  end

  def test_use_board_switches_active
    project.add_board("other")
    project.use_board("other")
    assert_equal "other", project.active_board.name
    assert_raises(January::Error) { project.use_board("nope") }
  end

  def test_boards_are_independent
    project.add_board("other")
    project.active_board.add_column("A")
    project.use_board("other")
    assert_equal [], project.active_board.columns
  end

  def test_remove_board_switches_active_when_needed
    project.add_board("other")
    project.use_board("other")
    project.remove_board("other")
    assert_equal "main", project.active_board_name
  end

  def test_last_board_cannot_be_removed
    error = assert_raises(January::Error) { project.remove_board("main") }
    assert_match(/at least one board/, error.message)
  end

  def test_roundtrip
    project.add_board("other")
    project.active_board.add_column("A")
    project.use_board("other")
    copy = January::Project.from_h(YAML.safe_load(YAML.dump(project.to_h)))
    assert_equal %w[main other], copy.board_names
    assert_equal "other", copy.active_board_name
    assert_equal %w[A], copy.find_board("main").columns
  end

  def test_legacy_project_becomes_the_main_board
    legacy = {
      "name" => "old", "columns" => %w[Todo Done],
      "cards" => [{ "id" => 1, "title" => "X", "description" => "", "column" => "Todo" }],
      "next_card_id" => 2
    }
    project = January::Project.from_h(legacy)
    assert_equal %w[main], project.board_names
    assert_equal %w[Todo Done], project.active_board.columns
    assert_equal ["X"], project.active_board.cards.map(&:title)
  end

  def test_invalid_project_name
    assert_raises(January::Error) { January::Project.new("a b") }
  end
end
