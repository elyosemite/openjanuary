module January
  class Project
    DEFAULT_BOARD = "main".freeze

    attr_reader :name, :boards

    def self.normalize(name)
      Naming.normalize(name)
    end

    def self.from_h(hash)
      boards = hash["boards"] ? hash["boards"].map { |b| Board.from_h(b) } : [Board.from_h(hash.merge("name" => DEFAULT_BOARD))]
      new(hash.fetch("name"), boards: boards, active_board: hash["active_board"])
    end

    def initialize(name, boards: nil, active_board: nil)
      @name = Naming.validate!(name, "project")
      @boards = boards ? boards.dup : [Board.create(DEFAULT_BOARD)]
      @active_board = active_board || @boards.first.name
    end

    def board_names
      @boards.map(&:name)
    end

    def active_board_name
      @active_board
    end

    def active_board
      find_board(@active_board)
    end

    def find_board(name)
      normalized = Naming.normalize(name)
      @boards.find { |b| b.name == normalized } || raise(Error, "Board '#{normalized}' not found.")
    end

    def add_board(name)
      board = Board.create(name)
      raise Error, "Board '#{board.name}' already exists." if board_names.include?(board.name)

      @boards << board
      board
    end

    def use_board(name)
      board = find_board(name)
      @active_board = board.name
      board
    end

    def remove_board(name)
      board = find_board(name)
      raise Error, "A project needs at least one board." if @boards.size == 1

      @boards.delete(board)
      @active_board = @boards.first.name if @active_board == board.name
      board
    end

    def to_h
      { "name" => name, "active_board" => @active_board, "boards" => boards.map(&:to_h) }
    end
  end
end
