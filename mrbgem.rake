require_relative 'lib/delayer/version'

MRuby::Gem::Specification.new('mruby-delayer') do |spec|
  spec.license     = 'MIT'
  spec.authors     = ['Toshiaki Asai', 'shibafu528']
  spec.version     = Delayer::VERSION
  spec.summary     = %q{Delay the processing}
  spec.description = %q{Delay the processing}

  spec.add_dependency 'mruby-struct', core: 'mruby-struct'
  spec.add_dependency 'mruby-set', mgem: 'mruby-set'
end
