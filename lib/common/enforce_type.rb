class EnforceType
  extend ClassFunctional
  def self.call object, *types
    unless types.include?(object.class)
      raise ArgumentError.new("expected a #{types.join(', ')}, got #{object.class}: #{object.inspect}")
    end
  end
end