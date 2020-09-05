class TestMrubyDelayer < MTest::Unit::TestCase
  def setup
    Delayer.default = nil
  end

  def test_reserve_hook
    delayer = Delayer.generate_class
    a = []
    delayer.register_reserve_hook do |delay|
      a << delay
    end
    delayer.new(delay: 1) {}
    delayer.new(delay: 0.1) {}
    delayer.new(delay: Time.new + 2) {}
    delayer.new(delay: Time.new - 1) {}

    [1, 0.1, 2, 0].zip(a).each do |(expected, actual)|
      assert_in_delta(expected, actual, 0.01)
    end
  end
end

if $ok_test
  MTest::Unit.new.mrbtest
else
  MTest::Unit.new.run
end
