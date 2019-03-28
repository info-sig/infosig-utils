redis_conn = proc {
  Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/3', namespace: "InfoSig/#{RACK_ENV}") # do anything you want here
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: ENV['MAX_THREADS'] || 1, &redis_conn)
end

module SidekiqInternalsHash
  def sidekiq_internals_hash= arg
    @sidekiq_internals_hash = arg
  end
  def sidekiq_internals_hash
    @sidekiq_internals_hash ||= {}
  end
end

class SidekiqInternalsMiddleware
  def call(worker, msg, queue)
    if worker.respond_to?(:sidekiq_internals_hash)
      worker.sidekiq_internals_hash = msg
    end

    yield
  end
end

# # ======================= BEGIN: SIDEKIQ SCHEDULER =============================
# Sidekiq::Scheduler.enabled = false
# Sidekiq::Scheduler.dynamic = false
#
# schedule = YAML.load_erb_file(InfoSig.root + "/config/scheduler.yml")
# Dir[InfoSig.root + "/modules/*/config/scheduler.yml"].each do |yaml|
#  schedule.merge! YAML.load_erb_file(yaml)
# end
#
# Sidekiq.schedule = schedule
# # ======================= END:   SIDEKIQ SCHEDULER =============================

Sidekiq.configure_server do |config|
  threads = config.options[:concurrency] = ( ENV['MAX_WORKER_THREADS'] || 4 ).to_i
  config.redis = ConnectionPool.new(size: threads + 1, &redis_conn)
  config.options[:verbose] = InfoSig.log.log_level == :debug
  config.options[:schedule] = Sidekiq.schedule

  config.server_middleware do |chain|
    chain.add SidekiqInternalsMiddleware
  end

  # set up Sidekiq Scheduler
  if InfoSig.primary_node?
    if $MASTER_SIDEKIQ_PROCESS
      InfoSig.log.info "Enabling Sidekiq scheduler"
      Sidekiq::Scheduler.enabled = true
      config.on(:startup) do
        Sidekiq.schedule = schedule
        Sidekiq::Scheduler.reload_schedule!
      end
    end
  else
    InfoSig.log.debug "No Sidekiq scheduler on backup host"
  end
end



if Sidekiq.server?
  REDIS = ConnectionPool.new(size: (ENV['MAX_WORKER_THREADS'] || 4).to_i + 1, &redis_conn)

else
  REDIS = ConnectionPool.new(size: (ENV['MAX_THREADS'] || 1).to_i + 1, &redis_conn)

end

# Redlock now
require "./lib/common/redlock_pooled_client"
REDLOCK = Redlock::PooledClient.new(REDIS)

# Cache now
require "./lib/common/cache"
CACHE = Cache.new(REDIS, namespace: "InfoSig/#{RACK_ENV}")