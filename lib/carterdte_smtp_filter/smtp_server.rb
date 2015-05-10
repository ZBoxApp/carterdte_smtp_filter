module CarterdteSmtpFilter
  
  class SmtpServer < MidiSmtpServer::Smtpd
    
     def initialize( port = CarterdteSmtpFilter::Config::bind_port, host = CarterdteSmtpFilter::Config::bind_address, max_connections = 4, opts = {})
       opts = { do_dns_reverse_lookup: false }
       super
     end
    
    def start
      
      super
    end
    
  end
  
end