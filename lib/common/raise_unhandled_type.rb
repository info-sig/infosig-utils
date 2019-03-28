class UnhandledTypeError < StandardError; end

class RaiseUnhandledType
  extend ClassFunctional
  def self.call object
    raise UnhandledTypeError.new("unhandled object type #{object.class} #{object.inspect}")
  end
end