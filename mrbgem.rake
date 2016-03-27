MRuby::Gem::Specification.new('mruby-delayer') do |spec|
  spec.license     = 'MIT'
  spec.authors     = ['Toshiaki Asai', 'shibafu528']
  spec.version     = '0.0.2'
  spec.summary     = %q{Delay the processing}
  spec.description = %q{Delay the processing}
  
  spec.add_dependency('mruby-thread', :github => 'mattn/mruby-thread')
end
