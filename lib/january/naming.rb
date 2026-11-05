module January
  module Naming
    FORMAT = /\A[a-z0-9][a-z0-9_-]*\z/

    def self.normalize(name)
      name.to_s.strip.downcase
    end

    def self.validate!(name, kind)
      normalized = normalize(name)
      return normalized if normalized.match?(FORMAT)

      raise Error, "Invalid #{kind} name '#{name}'. Use letters, digits, '-' or '_'."
    end
  end
end
