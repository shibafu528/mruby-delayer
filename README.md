# Delayer for mruby

[delayer](https://github.com/toshia/delayer) gemをmrubyにポーティングしたものです。

## Original Description

Delay Any task. Similar priority-queue.

## Installation

Add conf.gem line to your `build_config.rb`:

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'shibafu528/mruby-delayer'
end
```

## Usage

    Task = Delayer.generate_class # Define basic class
    Task = Delayer.generate_class(priority: [:high, :middle, :low], default: :middle) # or, Priority delayer
    Task = Delayer.generate_class(expire: 0.5) # and/or, Time limited delayer.
    
    task = Task.new { delayed code ... } # Register task
    task = Task.new(:high) { delayed code ... } # or, You can specify priority.
    
    task.cancel # Task can cancel before Delayer#run.
    
    Task.run # Execute all tasks.
    Task.run(1) # or, You can specify expire.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
