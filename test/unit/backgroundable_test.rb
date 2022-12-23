require 'test_helpers'

class BackgroundableTest < UnitTest

  class TestException < Exception; end

  class SomeWorker
    include Functional
    include Backgroundable

    def self.counter= arg
      @@counter = arg
    end

    def self.increment_counter
      @@counter = @@counter + 1
    end
    delegate :increment_counter, to: 'self.class'

    def self.counter
      @@counter
    end
    delegate :counter, to: 'self.class'

    def call options = {}
      raise TestException if options[:exception]
      increment_counter
      sleep(options[:sleep].to_f) if options[:sleep]
      counter
    end
  end

  setup do
    $__backgroundable_unique_test = true
    Sidekiq::Worker.clear_all
    SomeWorker.counter = SomeWorker::Future.counter = 0
  end

  teardown do
    $__backgroundable_unique_test = false
  end

  def test_job_is_done
    SomeWorker.perform_async; Sidekiq::Worker.drain_all
    assert_equal 1, SomeWorker.counter, 'expected the job to be successful'
  end

  def test_future_job_is_done
    rv = SomeWorker::Future.execute(:call)
    assert_equal Concurrent::Future, rv.class, 'SomeWorker::Future is wrong type'

    act = rv.value(0.00001)
    assert_nil act, 'expected the future to return nil before sidekiq is ran'
    Sidekiq::Worker.drain_all

    act = rv.value!
    assert_equal 1, SomeWorker::Future.counter, 'expected the job to be successful'
    assert_equal 1, act, 'expected the job to return a value'
  end

  def test_timeouts_work_as_expected_on_futures
    # Scenario 1: task takes longer to finish than the timeout parameter - and raises an exception as rejected
    rv = SomeWorker::Future.execute(:call, timeout: 1)
    Concurrent::Future.execute{ sleep 1.5; Sidekiq::Worker.drain_all }
    assert_raises(Timeout::Error){ rv.value! }

    # Scenario 2: task takes shorter to finish than the timeout parameter - and returns a value
    rv = SomeWorker::Future.execute(:call, timeout: 1)
    Sidekiq::Worker.drain_all
    act = rv.value!
    assert_equal 2, SomeWorker::Future.counter, 'expected the job to be successful - as well as the one from before - beware of this'
    assert_equal 2, act, 'expected the job to return a value'

    # Scenario 3: different method
    rv = SomeWorker::Future.execute(:increment_counter, timeout: 1)
    Sidekiq::Worker.drain_all
    act = rv.value!
    assert_equal 3, SomeWorker::Future.counter, 'expected the job to be successful - as well as the one from before - beware of this'
    assert_equal 3, act, 'expected the job to return a value'

  end

  def test_job_fail
    assert_raise TestException do
      SomeWorker.new.perform(exception: true)
    end
    SomeWorker.new.perform
    assert_equal 1, SomeWorker.counter, 'the non-exceptional task should have been executed, maybe a lock was still on?'
  end

  # def test_multiple_execution
  #   futures = 100.times.map{ Concurrent::Future.execute{ SomeWorker.new.perform(sleep: 1) } }
  #   futures.each(&:value!)
  #   assert_equal 1, SomeWorker.counter, "the job got executed wrong number of times"
  # end unless skip_stress_tests?
end
