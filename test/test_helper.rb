$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "january"

module TmpHome
  def setup
    super
    @home = Dir.mktmpdir("january")
  end

  def teardown
    FileUtils.remove_entry(@home)
    super
  end
end
