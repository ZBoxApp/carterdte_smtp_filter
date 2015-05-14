module CarterdteSmtpFilter
  
  module Config
    attr_accessor :config
    
    SPOOL_DIR = "/var/spool/carter_smtp_filter"
    
    def self.spool_dir
      @config["spool_dir"] || SPOOL_DIR
    end
    
    def self.parse(file = nil)
      @config = YAML.load_file(file)
    end
    
    def self.method_missing(m, *args, &block)
      option = m.to_s
      return get_value(option) unless /=$/.match(option)
      set_value(option, args[0])
    end
    
    def self.get_value(option)
      return false unless @config[option]
      @config[option].to_s
    end
    
    def self.set_value(option, value)
      @config[option.to_sym] = value
    end
    
        
  end
  
end