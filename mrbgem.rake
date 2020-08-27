require_relative 'lib/delayer/version'

MRuby::Gem::Specification.new('mruby-delayer') do |spec|
  spec.license     = 'MIT'
  spec.authors     = ['Toshiaki Asai', 'shibafu528']
  spec.version     = Delayer::VERSION
  spec.summary     = %q{Delay the processing}
  spec.description = %q{Delay the processing}

  spec.add_dependency 'mruby-struct', core: 'mruby-struct'
  spec.add_dependency 'mruby-set', github: 'mruby-Forum/mruby-set', branch: 'support-mruby-2.0.0'

  spec.add_test_dependency 'mruby-mtest', mgem: 'mruby-mtest'
  spec.add_test_dependency 'mruby-sleep', core: 'mruby-sleep'
  spec.add_test_dependency 'mruby-random', core: 'mruby-random'
end
