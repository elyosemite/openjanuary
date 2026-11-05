require "test_helper"

class WorkspaceTest < Minitest::Test
  include TmpHome

  def workspace
    @workspace ||= January::Workspace.new(January::Store.new(@home))
  end

  def test_add_project_persists_it
    workspace.add_project("finances")
    assert_equal %w[finances], workspace.project_names
    assert_equal "finances", workspace.find_project("finances").name
  end

  def test_name_is_normalized_to_lowercase
    workspace.add_project("  Finances ")
    assert_equal %w[finances], workspace.project_names
    assert_equal "finances", workspace.find_project("FINANCES").name
  end

  def test_duplicate_name_is_rejected
    workspace.add_project("work")
    error = assert_raises(January::Error) { workspace.add_project("Work") }
    assert_match(/already exists/, error.message)
  end

  def test_invalid_names_are_rejected
    ["", "a b", "../x", "a/b", "-x"].each do |name|
      assert_raises(January::Error, name) { workspace.add_project(name) }
    end
  end

  def test_first_project_becomes_active
    workspace.add_project("work")
    workspace.add_project("college")
    assert_equal "work", workspace.active_name
  end

  def test_use_project_switches_active
    workspace.add_project("work")
    workspace.add_project("college")
    workspace.use_project("college")
    assert_equal "college", workspace.active_project.name
  end

  def test_use_unknown_project_fails
    assert_raises(January::Error) { workspace.use_project("nope") }
  end

  def test_remove_project_deletes_it
    workspace.add_project("work")
    workspace.add_project("college")
    workspace.remove_project("college")
    assert_equal %w[work], workspace.project_names
    assert_equal "work", workspace.active_name
  end

  def test_removing_active_project_clears_selection
    workspace.add_project("work")
    workspace.remove_project("work")
    assert_nil workspace.active_name
    assert_raises(January::Error) { workspace.active_project }
  end

  def test_remove_unknown_project_fails
    assert_raises(January::Error) { workspace.remove_project("nope") }
  end

  def test_update_project_persists_changes
    workspace.add_project("work")
    workspace.update_project("work") { |project| project.active_board.add_column("Review") }
    assert_equal %w[Backlog Doing Done Review], workspace.find_project("work").active_board.columns
  end

  def test_update_project_does_not_persist_when_block_raises
    workspace.add_project("work")
    assert_raises(January::Error) do
      workspace.update_project("work") do |project|
        project.active_board.add_column("Review")
        project.active_board.add_column("review")
      end
    end
    assert_equal January::Board::DEFAULT_COLUMNS, workspace.find_project("work").active_board.columns
  end

  def test_update_board_targets_the_active_board
    workspace.add_project("work")
    workspace.update_project("work") { |project| project.add_board("other") && project.use_board("other") }
    workspace.update_board { |board| board.add_column("Only-here") }
    project = workspace.find_project("work")
    assert_equal January::Board::DEFAULT_COLUMNS + %w[Only-here], project.find_board("other").columns
    assert_equal January::Board::DEFAULT_COLUMNS, project.find_board("main").columns
  end
end
