require "test_helper"

class CardTest < Minitest::Test
  def project
    @project ||= January::Project.new("work").tap do |p|
      p.add_column("Backlog")
      p.add_column("Doing")
    end
  end

  def test_add_card_defaults_to_first_column_and_sequential_ids
    a = project.add_card("First")
    b = project.add_card("Second", description: "  details ")
    assert_equal [1, 2], [a.id, b.id]
    assert_equal "Backlog", a.column
    assert_equal "details", b.description
  end

  def test_add_card_into_named_column_ignoring_case
    assert_equal "Doing", project.add_card("X", column: "doing").column
  end

  def test_add_card_without_columns_fails
    assert_raises(January::Error) { January::Project.new("empty").add_card("X") }
  end

  def test_add_card_to_unknown_column_fails
    assert_raises(January::Error) { project.add_card("X", column: "Nope") }
  end

  def test_empty_title_is_rejected
    assert_raises(January::Error) { project.add_card("  ") }
  end

  def test_ids_are_not_reused_after_removal
    project.add_card("A")
    project.add_card("B")
    project.remove_card(2)
    assert_equal 3, project.add_card("C").id
  end

  def test_find_unknown_card_fails
    assert_raises(January::Error) { project.find_card(99) }
  end

  def test_move_card
    project.add_card("A")
    project.move_card(1, "doing")
    assert_equal "Doing", project.find_card(1).column
    assert_raises(January::Error) { project.move_card(1, "Nope") }
  end

  def test_update_card_changes_only_given_fields
    project.add_card("Old", description: "keep")
    project.update_card(1, title: "New")
    assert_equal ["New", "keep"], [project.find_card(1).title, project.find_card(1).description]
    project.update_card(1, description: "")
    assert_equal "", project.find_card(1).description
  end

  def test_update_card_rejects_empty_title
    project.add_card("A")
    assert_raises(January::Error) { project.update_card(1, title: " ") }
  end

  def test_cards_in_column
    project.add_card("A")
    project.add_card("B", column: "Doing")
    assert_equal ["B"], project.cards_in("Doing").map(&:title)
  end

  def test_roundtrip_keeps_cards_and_next_id
    project.add_card("A", description: "d")
    project.add_card("B")
    project.remove_card(2)
    copy = January::Project.from_h(project.to_h)
    assert_equal ["A"], copy.cards.map(&:title)
    assert_equal 3, copy.add_card("C").id
  end

  def test_remove_column_with_cards_is_blocked
    project.add_card("A")
    error = assert_raises(January::Error) { project.remove_column("Backlog") }
    assert_match(/--move-to/, error.message)
    assert_equal %w[Backlog Doing], project.columns
    assert_equal 1, project.cards.size
  end

  def test_remove_column_moving_cards
    project.add_card("A")
    project.remove_column("Backlog", move_to: "Doing")
    assert_equal "Doing", project.find_card(1).column
    assert_equal %w[Doing], project.columns
  end

  def test_remove_column_move_to_itself_fails
    project.add_card("A")
    assert_raises(January::Error) { project.remove_column("Backlog", move_to: "backlog") }
    assert_equal %w[Backlog Doing], project.columns
  end

  def test_remove_column_with_force_deletes_cards
    project.add_card("A")
    project.add_card("B", column: "Doing")
    project.remove_column("Backlog", force: true)
    assert_equal ["B"], project.cards.map(&:title)
  end
end
