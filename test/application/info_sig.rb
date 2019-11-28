module InfoSig

  def self.log
    AppLogger
  end

  # will raise in production env
  def self.get_env env_var, default = nil, options = {}
    if !ENV[env_var.to_s] && (!default || !development_system?)
      if options[:warn]
        warn "can't supply default value for #{env_var}, please set it explicitly"
      else
        raise "can't supply default value for #{env_var}, please set it explicitly"
      end
    elsif ENV[env_var.to_s]
      ENV[env_var.to_s]
    else
      default
    end
  end

  def self.pci_dss?
    @pci_dss = !development_system? || env?(:test) || !!ENV['PCI_DSS']
  end

  def self.env? arg
    env.to_s == arg.to_s
  end

  def self.env
    RACK_ENV
  end

  def self.development_system?
    !env?(:production) || !!ENV['DEVELOPMENT_SYSTEM']
  end

  def self.test?
    env?(:test)
  end

  def self.primary_node?
    !!ENV['PRIMARY_NODE']
  end

  def self.root
    @@root ||= File.expand_path File.dirname(__FILE__) + "/../.."
  end

  def self.installation
    ENV['INSTALLATION']
  end

  def self.installation_root
    return nil unless installation
    "#{root}/modules/#{installation}"
  end

  def self.require_files mask
    Dir[mask].sort.each {|file| require file }
  end

  def self.time_zone
    InfoSig.get_env('TZ', 'UTC')
  end
  time_zone # make sure if this doesn't work that it blow up in time

  log.info(
    pci_dss: pci_dss?,
    primary_node: primary_node?,
    development_system: development_system?,
    root: root,
    installation: installation,
    installation_root: installation_root,
    time_zone: time_zone
  )

end