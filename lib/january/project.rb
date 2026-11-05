module January
  class Project
    NAME_FORMAT = /\A[a-z0-9][a-z0-9_-]*\z/

    attr_reader :name

    def self.normalize(name)
      name.to_s.strip.downcase
    end

    def self.from_h(hash)
      new(hash.fetch("name"))
    end

    def initialize(name)
      @name = self.class.normalize(name)
      return if @name.match?(NAME_FORMAT)

      raise Error, "Invalid project name '#{name}'. Use letters, digits, '-' or '_'."
    end

    def to_h
      { "name" => name }
    end
  end
end
