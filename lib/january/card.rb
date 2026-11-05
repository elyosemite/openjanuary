module January
  class Card
    attr_reader :id
    attr_accessor :column, :era_id
    attr_reader :title, :description

    def self.from_h(hash)
      new(
        id: hash.fetch("id"),
        title: hash.fetch("title"),
        description: hash.fetch("description", ""),
        column: hash.fetch("column"),
        era_id: hash["era_id"]
      )
    end

    def initialize(id:, title:, column:, description: "", era_id: nil)
      @id = id
      @era_id = era_id
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
      { "id" => id, "title" => title, "description" => description, "column" => column, "era_id" => era_id }
    end
  end
end
