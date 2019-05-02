if defined?(Redlock)
  class Redlock::PooledClient < Struct.new(:redis_connection_pool)

    def lock *args, &block
      with_client{ |client| client.lock(*args, &block) }
    end

    def unlock *args, &block
      with_client{ |client| client.unlock(*args, &block) }
    end

    private

    def with_client
      rv = nil
      redis_connection_pool.with do |redis|
        client = Redlock::Client.new([redis])
        rv = yield client
      end
      rv
    end

  end
end