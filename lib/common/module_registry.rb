class ModuleRegistry

  delegate :each, :empty?, to: :all


  attr_accessor :ancestor_klass

  def initialize options = {}
    @ancestor_klass = options.delete(:ancestor)
  end

  def all
    @all ||= {}
  end

  def add new_modules, options = {}
    new_modules = new_modules.stringify_keys

    mutual_keys = new_modules.keys & all.keys
    if mutual_keys.any?
      raise(ArgumentError.new("modules #{mutual_keys} have already been defined"))
    end

    if ancestor_klass
      new_modules.each do |k, v|
        v_class = v
        v_class = v.class unless v.is_a?(Class) or v.is_a?(Module)
        raise(ArgumentError.new("module #{k} must inherit from #{ancestor_klass}")) unless v_class < ancestor_klass
      end
    end

    all.merge! new_modules
  end

  def resolve mod, options = {}
    rv = all[mod.to_s]
    raise(ArgumentError.new("unsupported module #{mod}")) if !rv and !options[:allow_nil]

    rv
  end

end