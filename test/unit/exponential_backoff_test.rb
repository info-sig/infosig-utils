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

    assert waits.sum > 1.8, "expected total wait > 1.8 (got #{'%.3f' % waits.sum})"
    assert waits.sum < 2.0, "expected total wait < 2.0 (got #{'%.3f' % waits.sum})"
    assert waits.max >= 0.51, "expected no wait >= 0.51 (max was #{'%.3f' % waits.max})"
  end

end