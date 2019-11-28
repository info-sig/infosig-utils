class RedisKey
  extend ClassFunctional

  # TODO: deprecate and replace with CacheKey

  def self.call string
    if InfoSig.env == :test
      "#{Thread.current[:test_run_uid]}/#{string}"
    else
      string
    end
  end

end