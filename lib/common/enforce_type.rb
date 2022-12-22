class EnforceType
  extend ClassFunctional
  def self.call object, *types
    opts = ExtractOptions[types, bang: true]
    exception_class = opts[:ex] || ArgumentError

    unless types.include?(object.class)
      raise exception_class.new("expected a #{types.join(', ')}, got #{object.class}: #{object.inspect}")
    end
    object
  end
end