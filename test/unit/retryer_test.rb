require "test_helpers"

class RetryerTest < UnitTest

  def test_value_is_returned_on_valid_call
    rv = Retryer.call { 'test rv' }

    assert_equal 'test rv', rv, 'rv is off.'
  end

  def test_no_logs_produced_on_valid_call
    _, logs = capture_io do
      Retryer.call { 'test rv' }
    end

    expected_logs = ''
    assert_equal expected_logs, logs, 'logs are off.'
  end

  def test_retries_for_default_number_of_times
    _, logs = capture_io do
      assert_raise Exception do
        Retryer.call { throw('wee:)') }
      end
    end

    assert_includes logs, 'retry 2 of 2', 'number of retries is off.'
  end

  def test_retries_for_given_number_of_times
    _, logs = capture_io do
      assert_raise Exception do
        Retryer.call({repeats: 3}) { throw('wee:)') }
      end
    end

    assert_includes logs, 'retry 3 of 3', 'number of retries is off.'
  end

  def test_produces_log_for_each_retry
    _, logs = capture_io do
      assert_raise Exception do
        Retryer.call { throw('wee:)') }
      end
    end

    expected_logs = 'UncaughtThrowError: uncaught throw "wee:)", retry 1 of 2
UncaughtThrowError: uncaught throw "wee:)", retry 2 of 2
'
    assert_equal expected_logs, logs, 'logs are off.'
  end

  def test_raises_exception_after_max_retires
    capture_io do
      assert_raise Exception do
        Retryer.call { throw('wee:)') }
      end
    end
  end

  def test_sleeps_for_a_given_duration
    start_time = Time.now
    assert_raise Exception do
      Retryer.call({repeats: 2, sleeps: 1}) { throw('wee:)') }
    end
    end_time = Time.now
    elapsed_time = end_time - start_time
    assert_operator elapsed_time, :>=, 2, "Code did not take at least 2 seconds to execute"
  end
end
