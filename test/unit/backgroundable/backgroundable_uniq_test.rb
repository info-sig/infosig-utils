require 'test_helpers'

module Backgroundable

  class TestException < Exception; end

  class BackgroundableUniqTest < UnitTest
    # register_multi_threaded_tests :test_multiple_execution

    class DummyUniqWorker
      include Backgroundable::Unique

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
        sleep(options[:sleep].to_i) if options[:sleep]
      end
    end

    setup do
      $__backgroundable_unique_test = true
      DummyUniqWorker.counter = 0
    end

    teardown do
      $__backgroundable_unique_test = false
    end

    def test_job_is_done
      DummyUniqWorker.new.perform
      assert_equal 1, DummyUniqWorker.counter, 'expected the job to be successful'
    end

    def test_job_fail
      assert_raise TestException do
        DummyUniqWorker.new.perform(exception: true)
      end
      DummyUniqWorker.new.perform
      assert_equal 1, DummyUniqWorker.counter, 'the non-exceptional task should have been executed, maybe a lock was still on?'
    end

    # def test_multiple_execution
    #   futures = 100.times.map{ Concurrent::Future.execute{ DummyUniqWorker.new.perform(sleep: 1) } }
    #   futures.each(&:value!)
    #   assert_equal 1, DummyUniqWorker.counter, "the job got executed wrong number of times"
    # end unless skip_stress_tests?
  end

end