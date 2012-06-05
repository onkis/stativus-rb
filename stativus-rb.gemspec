Gem::Specification.new do |s|
	s.name            = "stativus"
	s.version         = "0.0.1"
	#s.platform        = Gem::Platform::RUBY todo: need this?
	s.summary         = "a ruby statechart library"

	s.description = "Stativus provides a way to define state in a client facing application. 
It is a port of the stativus.js library."

	s.files           = ["license.txt", ".gitignore", "Rakefile", "lib/stativus.rb", "tests/*.rb"]
	s.require_paths = ["lib"]

	s.extra_rdoc_files = ['README']
	s.test_files      = Dir['tests/*.rb']


	s.author          = 'Mike Ball'
	s.email           = 'mike.ball3@gmail.com'
	s.homepage        = 'http://github.com/onkis/stativus-rb'
	#s.rubyforge_project = 'rack'

	s.add_development_dependency 'rake'
end
