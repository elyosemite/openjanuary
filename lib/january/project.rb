module January
  class Project
    NAME_FORMAT = /\A[a-z0-9][a-z0-9_-]*\z/

    attr_reader :name, :columns

    def self.normalize(name)
      name.to_s.strip.downcase
    end

    def self.from_h(hash)
      new(hash.fetch("name"), columns: hash.fetch("columns", []))
    end

    def initialize(name, columns: [])
      @name = self.class.normalize(name)
      @columns = columns.dup
      return if @name.match?(NAME_FORMAT)

      raise Error, "Invalid project name '#{name}'. Use letters, digits, '-' or '_'."
    end

    def add_column(name)
      name = name.to_s.strip
      raise Error, "Column name cannot be empty." if name.empty?
      raise Error, "Column '#{find_column(name)}' already exists." if find_column(name)

      @columns << name
      name
    end

    def remove_column(name)
      column = fetch_column(name)
      @columns.delete(column)
      column
    end

    def move_column(name, position)
      column = fetch_column(name)
      unless position.between?(1, @columns.size)
        raise Error, "Position must be between 1 and #{@columns.size}."
      end

      @columns.delete(column)
      @columns.insert(position - 1, column)
      column
    end

    def to_h
      { "name" => name, "columns" => columns }
    end

    private

    def find_column(name)
      @columns.find { |c| c.casecmp?(name.to_s.strip) }
    end

    def fetch_column(name)
      find_column(name) || raise(Error, "Column '#{name.to_s.strip}' not found.")
    end
  end
end
