require "date"

module January
  class Era
    attr_reader :id, :name, :starts_on, :ends_on, :closed_on

    def self.from_h(hash)
      new(
        id: hash.fetch("id"),
        name: hash.fetch("name"),
        starts_on: parse(hash.fetch("starts_on")),
        ends_on: parse(hash["ends_on"]),
        closed_on: parse(hash["closed_on"])
      )
    end

    def self.parse(value)
      return nil if value.nil?
      return value if value.is_a?(Date)

      Date.iso8601(value.to_s)
    rescue Date::Error
      raise Error, "Invalid date '#{value}'. Use YYYY-MM-DD."
    end

    def initialize(id:, name:, starts_on:, ends_on: nil, closed_on: nil)
      name = name.to_s.strip
      raise Error, "Era name cannot be empty." if name.empty?
      raise Error, "The era cannot end before it starts." if ends_on && ends_on < starts_on

      @id = id
      @name = name
      @starts_on = starts_on
      @ends_on = ends_on
      @closed_on = closed_on
    end

    def active?
      closed_on.nil?
    end

    def close(date)
      @closed_on = date
    end

    def to_h
      {
        "id" => id,
        "name" => name,
        "starts_on" => starts_on.iso8601,
        "ends_on" => ends_on&.iso8601,
        "closed_on" => closed_on&.iso8601
      }
    end
  end
end
