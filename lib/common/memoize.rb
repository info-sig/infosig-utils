class Memoize
  include Functional

  def initialize
    @last_check_timestamp = 100.years.ago
    @value = nil
    @test_run_uid = $test_run_uid
  end

  def call options = {}
    expire_in = options[:expire_in] || 1.minute

    if @last_check_timestamp < expire_in.ago or @test_run_uid != $test_run_uid
      @value = yield
      @last_check_timestamp = Time.now
    end

    self
  end

  def value
    @value
  end

end
