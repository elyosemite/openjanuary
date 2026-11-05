require "test_helper"

class StoreTest < Minitest::Test
  include TmpHome

  def store
    @store ||= January::Store.new(@home)
  end

  def test_write_then_read_roundtrip
    store.write("projects/a.yml", { "name" => "a", "cards" => [1, 2] })
    assert_equal({ "name" => "a", "cards" => [1, 2] }, store.read("projects/a.yml"))
  end

  def test_read_missing_returns_nil
    assert_nil store.read("projects/none.yml")
  end

  def test_write_leaves_no_temp_files
    store.write("projects/a.yml", { "x" => 1 })
    assert_equal ["a.yml"], Dir.children(File.join(@home, "projects"))
  end

  def test_overwrite_replaces_content
    store.write("config.yml", { "v" => 1 })
    store.write("config.yml", { "v" => 2 })
    assert_equal 2, store.read("config.yml")["v"]
  end

  def test_delete_removes_file_and_ignores_missing
    store.write("projects/a.yml", {})
    store.delete("projects/a.yml")
    store.delete("projects/a.yml")
    assert_nil store.read("projects/a.yml")
  end

  def test_list_returns_sorted_names_without_extension
    store.write("projects/b.yml", {})
    store.write("projects/a.yml", {})
    assert_equal %w[a b], store.list("projects")
    assert_equal [], store.list("missing")
  end

  def test_corrupted_file_raises_january_error
    FileUtils.mkdir_p(File.join(@home, "projects"))
    File.write(File.join(@home, "projects/bad.yml"), "a: [unclosed")
    assert_raises(January::Error) { store.read("projects/bad.yml") }
  end

  def test_default_home_honors_env
    ENV["JANUARY_HOME"] = "/tmp/xyz"
    assert_equal "/tmp/xyz", January::Store.default_home
  ensure
    ENV.delete("JANUARY_HOME")
  end
end
