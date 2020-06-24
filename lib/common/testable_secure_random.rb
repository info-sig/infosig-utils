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


  private

  def faker_active?
    ::Rails.env.test? && @faker_active
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
