class InstanceCache
  extend ClassFunctional

  # if cache is supplied the InstanceCache will memoize the block result under the cache_key
  # if cache is not supplied it will simply yield the block
  def self.call cache, cache_key
    if cache
      cache.fetch(cache_key) do
        cache[cache_key] = yield
      end
    else
      yield
    end
  end

end