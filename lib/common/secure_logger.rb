class SecureLogger
  include Functional

  def initialize opts = {}
    @pan = opts.delete(:pan)
    @prohibited = opts.delete(:prohibited) || {}
  end

  def call string
    pci_dss_mask(string)
  end

  # use this instead of logger.debug
  def log(string, level = :debug)
    Event.log_and_go{ InfoSig.log.send(level, pci_dss_mask(string)) } # protect against exceptions
  end


  private

  # for masking log output
  #    -> defensive coding, we don't want this to break processing, ever
  def pci_dss_mask(string)
    if InfoSig.env?(:development)
      string
    else
      mask_each(string.to_s, ([@pan.to_s[6...-4]]+@prohibited).map(&:to_s))
    end
  end

  def mask_each(s, mask_array)
    rv = s.dup
    mask_array.each do |s|
      rv.gsub!(s, '*' * s.length)
    end

    rv
  end
    
end
