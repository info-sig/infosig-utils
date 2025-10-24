class CacheKey
  extend ClassFunctional
  def self.call string
    test_env = InfoSig.respond_to?(:env?) ? ::InfoSig.env?(:test) : ::InfoSig.env.test?
    
    if test_env
      raise "You need to define a test run uid in $test_run_uid" unless $test_run_uid
      "#{$test_run_uid}/#{string}"
    else
      string
    end
  end
end