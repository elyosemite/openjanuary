require "date"

module January
  VERSION = "0.1.0"

  class Error < StandardError; end
end

require_relative "january/naming"
require_relative "january/store"
require_relative "january/era"
require_relative "january/card"
require_relative "january/board"
require_relative "january/project"
require_relative "january/workspace"
require_relative "january/board_renderer"
require_relative "january/cli/project"
require_relative "january/cli/column"
require_relative "january/cli/card"
require_relative "january/cli/era"
require_relative "january/cli/board"
require_relative "january/cli"
