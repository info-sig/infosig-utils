require 'test_helpers'


class BackgroundableUniqTest < UnitTest
  # register_multi_threaded_tests :test_multiple_execution

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

    def self.counter
      @@counter
    end

    def call options = {}
      raise TestException if options[:exception]
      self.class.increment_counter
      sleep(options[:sleep].to_f) if options[:sleep]
      self.class.counter
    end
  end

  setup do
    $__backgroundable_unique_test = true
    SomeWorker.counter = 0
  end

  teardown do
    $__backgroundable_unique_test = false
  end

  def test_job_is_done
    SomeWorker.perform_async; Sidekiq::Worker.drain_all
    assert_equal 1, SomeWorker.counter, 'expected the job to be successful'
  end

  def test_future_job_is_done
    rv = SomeWorker::Future.execute(sleep: 0.1)
    assert_equal Concurrent::Future, rv.class, 'SomeWorker::Future is wrong type'

    act = rv.value(0.1)
    assert_nil act, 'expected the future to return nil before sidekiq is ran'
    Sidekiq::Worker.drain_all

    act = rv.value!
    assert_equal 1, SomeWorker::Future.counter, 'expected the job to be successful'
    assert_equal 1, act, 'expected the job to return a value'
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
