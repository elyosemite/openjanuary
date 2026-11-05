require "test_helper"

class ProjectTest < Minitest::Test
  def project
    @project ||= January::Project.new("work")
  end

  def test_starts_without_columns
    assert_equal [], project.columns
  end

  def test_add_column_keeps_order_and_case
    project.add_column("Backlog")
    project.add_column("  Doing ")
    assert_equal %w[Backlog Doing], project.columns
  end

  def test_duplicate_column_is_rejected_ignoring_case
    project.add_column("Backlog")
    error = assert_raises(January::Error) { project.add_column("backlog") }
    assert_match(/already exists/, error.message)
  end

  def test_empty_column_is_rejected
    assert_raises(January::Error) { project.add_column("   ") }
  end

  def test_remove_column_ignores_case
    project.add_column("Backlog")
    project.add_column("Done")
    assert_equal "Backlog", project.remove_column("BACKLOG")
    assert_equal %w[Done], project.columns
  end

  def test_remove_unknown_column_fails
    assert_raises(January::Error) { project.remove_column("Nope") }
  end

  def test_move_column_to_front_middle_and_end
    %w[A B C D].each { |c| project.add_column(c) }
    project.move_column("D", 1)
    assert_equal %w[D A B C], project.columns
    project.move_column("A", 3)
    assert_equal %w[D B A C], project.columns
    project.move_column("D", 4)
    assert_equal %w[B A C D], project.columns
  end

  def test_move_rejects_out_of_range_position
    project.add_column("A")
    assert_raises(January::Error) { project.move_column("A", 0) }
    assert_raises(January::Error) { project.move_column("A", 2) }
  end

  def test_move_unknown_column_fails
    assert_raises(January::Error) { project.move_column("Nope", 1) }
  end

  def test_roundtrip_through_hash
    project.add_column("Backlog")
    copy = January::Project.from_h(project.to_h)
    assert_equal %w[Backlog], copy.columns
  end

  def test_loads_legacy_hash_without_columns
    assert_equal [], January::Project.from_h("name" => "old").columns
  end

  def test_columns_are_not_shared_with_caller_array
    source = %w[A]
    January::Project.new("x", columns: source).add_column("B")
    assert_equal %w[A], source
  end
end
