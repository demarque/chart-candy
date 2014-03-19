$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "chart-candy"
  s.version     = "0.1.0"
  s.authors     = ["Sebastien Rosa"]
  s.email       = ["sebastien@demarque.com"]
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.licenses    = ["MIT"]
  s.homepage    = "https://github.com/demarque/chart-candy"
  s.summary     = "Chart Candy use D3.js library to quickly render AJAX charts in your Rails project. In a minimum amount of code, you should have a functional chart, styled and good to go."
  s.description = "Chart Candy use D3.js library to quickly render AJAX charts in your Rails project. In a minimum amount of code, you should have a functional chart, styled and good to go."

  s.rubyforge_project = "chart-candy"

  s.files         = Dir.glob('{app,config,lib,spec,vendor}/**/*') + %w(LICENSE README.md Rakefile Gemfile)
  s.require_paths = ["lib"]

  s.add_runtime_dependency "spreadsheet"
  s.add_development_dependency('rake', ['>= 0.8.7'])
  s.add_development_dependency('rspec', ['>= 2.0'])
end
