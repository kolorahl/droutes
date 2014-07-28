Gem::Specification.new do |s|
  s.name        = "droutes"
  s.version     = "0.0.8"
  s.date        = "2014-07-28"
  s.summary     = "Ruby REST documentation generator for client integration."
  s.description = "Generating documentation for REST endpoints for client developers can be a pain, but droutes can make it easy."
  s.authors     = ["Tyler Margison"]
  s.email       = "kolorahl@gmail.com"
  s.files       = ["README.md",
                   "LICENSE",
                   "Gemfile", "Gemfile.lock",
                   "lib/droutes.rb",
                   "lib/droutes/parser.rb",
                   "lib/generators/droutes/doc/doc_generator.rb",
                   "lib/generators/droutes/doc/templates/index.html",
                   "lib/generators/droutes/doc/templates/controller.html"]
  s.homepage    = "https://github.com/kolorahl/droutes"
  s.license     = "GPLv3"
end
