module MultiThreaded
  extend ActiveSupport::Concern

  def multi_threaded?
    self.class.multi_threaded_tests.include? name
  end

  module ClassMethods

    def register_multi_threaded_tests *tests
      @multi_threaded_tests ||= tests.map(&:to_s)
    end

    def multi_threaded_tests
      defined?(@multi_threaded_tests) || []
    end
  end
end