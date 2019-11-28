class CallbackGenerator

  IDEM = lambda{|&block| block.call}

  def initialize options
    @options = options.with_indifferent_access
  end

  def generate id, opts = {}
    rv = nil
    opts = opts.clone

    around = @options["around_#{id}"]

    call_proc("before_#{id}", opts)
    if around
      rv = call_proc("around_#{id}", opts){ yield(opts) }
    else
      rv = yield(opts)
    end
    call_proc("after_#{id}", opts)

    rv
  end

  private

  def call_proc proc_name, opts, &block
    proc = @options[proc_name]
    return nil unless proc

    if proc.arity == 0
      return proc.call(&block)

    elsif proc.arity == 1
      return proc.call(opts, &block)

    else
      raise ArgumentError.new("proc #{proc_name}'s arity is #{proc.arity} and should be 0 or 1")

    end
  end

end