class SymbolRegistry < SafeHash

  def []=(k,v)
    raise ArgumentError.new("#{k} is already defined") if has_key?(k)
    super(k, v)
  end

end