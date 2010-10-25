# -*- encoding: utf-8 ; mode: ruby -*-

Gem::Specification.new do |s|
  s.name              = 'sheepsafe'
  s.version           = '0.1'
  s.date              = '2010-10-25'

  s.rubyforge_project = %q{caldersphere}

  s.summary     = "Makes sure you're safe from FireSheep!"
  s.description = "Automatically toggle network locations and start a SOCKS proxy on untrusted networks. Mac OS X only."

  s.authors  = ["Nick Sieger"]
  s.email    = 'nick@nicksieger.com'
  s.homepage = 'http://github.com/nicksieger/sheepsafe'
  s.require_paths = %w[lib]
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  # = MANIFEST =
  s.files = %w[

  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*spec.*\.rb/ }

  s.add_dependency(%q<daemons>, ["~> 1.1"])
  s.add_development_dependency(%q<rspec>, ["~> 2.0"])

  s.rubygems_version = %q{1.3.7}
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
