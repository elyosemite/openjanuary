require "test_helper"

class CliProjectTest < Minitest::Test
  include TmpHome
  include CliHelper

  def test_add_and_list
    assert_match(/Created project 'finances'/, january("project", "add", "finances"))
    january("project", "add", "work")
    listing = january("project", "list")
    assert_includes listing, "* finances"
    assert_includes listing, "  work"
  end

  def test_list_when_empty
    assert_match(/No projects yet/, january("project", "list"))
  end

  def test_use_switches_active
    january("project", "add", "a")
    january("project", "add", "b")
    january("project", "use", "b")
    assert_includes january("project", "list"), "* b"
  end

  def test_remove_with_yes_flag
    january("project", "add", "a")
    assert_match(/Removed project 'a'/, january("project", "remove", "a", "--yes"))
    assert_match(/No projects yet/, january("project", "list"))
  end

  def test_remove_asks_for_confirmation_and_can_abort
    january("project", "add", "a")
    assert_match(/Aborted/, january("project", "remove", "a", input: "n\n"))
    assert_includes january("project", "list"), "a"
  end

  def test_remove_confirmed_by_answer
    january("project", "add", "a")
    assert_match(/Removed/, january("project", "remove", "a", input: "y\n"))
  end

  def test_unknown_project_reports_error
    assert_match(/january: Project 'zzz' not found/, january("project", "use", "zzz"))
  end

  def test_version_flag
    assert_equal "#{January::VERSION}\n", january("--version")
  end
end
