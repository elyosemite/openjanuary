require "yaml"
require "fileutils"

module January
  class Store
    def self.default_home
      ENV["JANUARY_HOME"] || File.join(Dir.home, ".january")
    end

    attr_reader :home

    def initialize(home = self.class.default_home)
      @home = home
    end

    def read(relative_path)
      path = path_for(relative_path)
      return nil unless File.exist?(path)

      YAML.safe_load_file(path, permitted_classes: [Symbol, Date, Time])
    rescue Psych::Exception => e
      raise Error, "Corrupted data file #{path}: #{e.message}"
    end

    def write(relative_path, data)
      path = path_for(relative_path)
      FileUtils.mkdir_p(File.dirname(path))
      tmp = "#{path}.tmp-#{Process.pid}"
      File.write(tmp, YAML.dump(data))
      File.rename(tmp, path)
    ensure
      File.delete(tmp) if tmp && File.exist?(tmp)
    end

    def delete(relative_path)
      path = path_for(relative_path)
      File.delete(path) if File.exist?(path)
    end

    def list(relative_dir, extension: ".yml")
      dir = path_for(relative_dir)
      return [] unless Dir.exist?(dir)

      Dir.children(dir).select { |f| f.end_with?(extension) }.map { |f| File.basename(f, extension) }.sort
    end

    private

    def path_for(relative_path)
      File.join(home, relative_path)
    end
  end
end
