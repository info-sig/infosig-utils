module TestableSecureRandom

  cattr_accessor :seed, :scope

  def make_deterministic! scope
    @faker_active = true
    self.seed = 0
    self.scope = scope
  end

  def make_random!
    @faker_active = false
    self.seed = nil
  end

  def base64 n = 20
    if faker_active?
      Base64.strict_encode64(next_seed(n))
    else
      SecureRandom.base64(n)
    end
  end

  def hex n = 20
    if faker_active?
      to_hex(next_seed(n))
    else
      SecureRandom.hex(n)
    end
  end

  def uuid
    if faker_active?
      "#{hex(4)}-#{hex(2)}-#{hex(2)}-#{hex(2)}-#{hex(6)}"
    else
      SecureRandom.uuid
    end
  end

  def rand int = nil
    if int
      if faker_active?
        Base64.decode64(next_seed).unpack('q*').first.abs % int
      else
        Random.rand(int)
      end

    else
      if faker_active?
        rand(10**16).to_f/10**16
      else
        Random.rand
      end

    end
  end


  private

  def faker_active?
    ::InfoSig.env.to_sym == :test && @faker_active
  end

  def next_seed(length = 20)
    self.seed += 1
    Digest::SHA512.base64digest(scope.to_s + '|' + seed.to_s).ljust(length, ' ')[0...length]
  end

  def to_hex bytes
    bytes.unpack('H*').first
  end


  extend self

end
