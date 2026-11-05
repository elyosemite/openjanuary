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

module CliHelper
  def january(*args, input: nil)
    ENV["JANUARY_HOME"] = @home
    out, err = StringIO.new, StringIO.new
    old_out, old_err, old_in = $stdout, $stderr, $stdin
    $stdout, $stderr = out, err
    $stdin = StringIO.new(input) if input
    begin
      January::CLI.start(args)
    rescue SystemExit
      nil
    rescue January::Error => e
      err.puts "january: #{e.message}"
    ensure
      $stdout, $stderr, $stdin = old_out, old_err, old_in
      ENV.delete("JANUARY_HOME")
    end
    out.string + err.string
  end
end
