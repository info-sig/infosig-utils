if defined?(Redlock)
  class Redlock::PooledClient < Struct.new(:redis_connection_pool)

    def lock *args
      unless block_given?
          with_client{ |client| client.lock(*args) }
      else
          begin
            lock = with_client{ |client| client.lock(*args) }
            yield lock
          ensure
            self.unlock(lock)
          end
      end
    end

    def unlock *args, &block
      with_client{ |client| client.unlock(*args, &block) }
    end

    def locked? *args, &block
      with_client{ |client| client.locked?(*args, &block)}
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
