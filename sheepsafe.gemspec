# -*- encoding: utf-8 ; mode: ruby -*-

Gem::Specification.new do |s|
  s.name              = 'sheepsafe'
  s.version           = '0.3.2'
  s.date              = '2011-06-05'

  s.rubyforge_project = %q{caldersphere}

  s.summary     = "Makes sure you're safe from FireSheep!"
  s.description = "Automatically toggle network locations and start a SOCKS proxy on untrusted networks. Mac OS X only."

  s.authors  = ["Nick Sieger"]
  s.email    = 'nick@nicksieger.com'
  s.homepage = 'http://github.com/nicksieger/sheepsafe'
  s.require_paths = %w[lib]
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.executables = ["sheepsafe"]

  s.post_install_message = %[
===========================================================================
Welcome to Sheepsafe!

=8P <=== (That\'s a sheep emoji.)

If this is your first time using Sheepsafe, you probably want to set it up.

To do that, run \`sheepsafe install\' now.

If you\'re updating to a new version of Sheepsafe and want to keep your
current configuration, run \`sheepsafe update\'.
===========================================================================
  ]

  # = MANIFEST =
  s.files = %w[
    History.txt
    LICENSE
    README.md
    Rakefile
    bin/sheepsafe
    lib/sheepsafe.rb
    lib/sheepsafe/config.rb
    lib/sheepsafe/controller.rb
    lib/sheepsafe/installer.rb
    lib/sheepsafe/network.rb
    sheepsafe.gemspec
    spec/sheepsafe_spec.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*spec.*\.rb/ }

  s.add_dependency(%q<highline>, ["~> 1.6"])
  s.add_dependency(%q<daemons>, ["~> 1.1"])
  s.add_development_dependency(%q<rspec>, ["~> 2.0"])

  s.rubygems_version = %q{1.3.7}
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
