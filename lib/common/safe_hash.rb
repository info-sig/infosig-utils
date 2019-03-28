class SafeHash < HashWithIndifferentAccess

  class MissingKey < StandardError; end

  def [](k)
    raise MissingKey.new("#{k}, got: #{keys}") unless has_key?(k)
    super(k)
  end

end