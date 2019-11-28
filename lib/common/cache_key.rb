class CacheKey
  extend ClassFunctional
  def self.call string
    if ::InfoSig.env?(:test)
      raise "You need to define a test run uid in $test_run_uid" unless $test_run_uid
      "#{$test_run_uid}/#{string}"
    else
      string
    end
  end
end