module January
  class Card
    attr_reader :id
    attr_accessor :column
    attr_reader :title, :description

    def self.from_h(hash)
      new(
        id: hash.fetch("id"),
        title: hash.fetch("title"),
        description: hash.fetch("description", ""),
        column: hash.fetch("column")
      )
    end

    def initialize(id:, title:, column:, description: "")
      @id = id
      @column = column
      self.title = title
      self.description = description
    end

    def title=(value)
      value = value.to_s.strip
      raise Error, "Card title cannot be empty." if value.empty?

      @title = value
    end

    def description=(value)
      @description = value.to_s.strip
    end

    def to_h
      { "id" => id, "title" => title, "description" => description, "column" => column }
    end
  end
end
