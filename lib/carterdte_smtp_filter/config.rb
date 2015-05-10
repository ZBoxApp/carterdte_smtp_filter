module CarterdteSmtpFilter
  
  module Config
    attr_accessor :config
    OPTIONS = %w(bind_address bind_port return_host return_port elasticsearch_host elasticsearch_port)
    
    def self.parse(file = nil)
      @config = YAML.load_file(file)
    end
    
    OPTIONS.each do |op|
      self.class.instance_eval do
        define_method(op) {@config[op].to_s}
      end
    end
        
  end
  
end