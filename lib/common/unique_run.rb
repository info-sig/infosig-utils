class UniqueRun
  extend ClassFunctional

  def self.call locking_key, options = {}
    lock_timeout = options.delete(:lock_timeout) || 30.seconds
    lock = REDLOCK.lock("UniqueRun/lock/" + locking_key, lock_timeout)
    if !(InfoSig.test? && !$__backgroundable_unique_test) && !lock
      InfoSig.log.info "execution in progress, quitting"
      return
    end

    yield
  ensure
    REDLOCK.unlock(lock) if lock

  end

end