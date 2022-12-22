class ExtractOptions
  extend ClassFunctional

  def self.call ary, opts = {}
    bang = opts[:bang]

    if ary.last.is_a?(Hash) && extractable_options?(ary.last)
      bang ? ary.pop : ary.last
    else
      {}
    end
  end


  private

  def self.extractable_options? el
    el.instance_of?(Hash)
  end

end