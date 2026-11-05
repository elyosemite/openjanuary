require_relative "lib/january"

Gem::Specification.new do |spec|
  spec.name = "january"
  spec.version = January::VERSION
  spec.summary = "A calm project manager for the terminal"
  spec.description = "Projects, columns, cards and eras on a board that lives in your terminal and stores plain YAML files."
  spec.license = "MIT"
  spec.authors = ["OpenJanuary contributors"]
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*.rb", "bin/january", "README.md"]
  spec.bindir = "bin"
  spec.executables = ["january"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"
end
