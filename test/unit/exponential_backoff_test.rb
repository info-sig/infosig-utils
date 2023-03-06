require "test_helpers"

class ExponentialBackoffTest < UnitTest

  parallelize_me!

  setup do
  end

  def test_basic_sync_use
    idx = 0
    waits = []
    start_time = Time.now
    ExponentialBackoff.call(max_sleep: 0.5, timeout: 2, nolog: true){ idx+=1; waits << Time.now-start_time-waits.sum; raise "foo" }

    assert waits.sum > 1.8, 'expected the total wait time to be close to 2'
    assert waits.sum < 2,   'expected the total wait time to not exceed 2'
    assert waits.max < 0.51, 'expected that no wait was bigger than max_sleep'
  end

end