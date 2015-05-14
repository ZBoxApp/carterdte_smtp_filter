module CarterdteSmtpFilter
  
  module Spool
    
    
    def self.directory_setup
      build_spool
      build_spool_structure
    end
    
    def self.spool_directory
      CarterdteSmtpFilter::Config::spool_directory
    end
    
    def self.build_spool
      FileUtils.mkdir_p spool_directory
    end
    
    def self.build_spool_structure
      (("A".."F").to_a + (0..9).to_a).each do |d|
        base_dir = "#{spool_directory}/#{d.to_s}"
        FileUtils.mkdir_p base_dir
      end
    end
    
  end
  
  
end