module Backgroundable
  module Unique
    extend ActiveSupport::Concern

    include Backgroundable

    included do
      prepend Backgroundable::Unique

      sidekiq_options :retry => 1
      sidekiq_options :lock_timeout => 120_00
    end


    def perform *args, &block
      lock = REDLOCK.lock("Backgroundable::Unique/lock/" + self.class.name.to_s, sidekiq_options_hash['lock_timeout'].to_i)
      if !(InfoSig.test? && !$__backgroundable_unique_test) && !lock
        InfoSig.log.info "execution in progress, quitting"
        return
      end

      super(*args, &block)
    ensure
      REDLOCK.unlock(lock) if lock

    end

  end
end