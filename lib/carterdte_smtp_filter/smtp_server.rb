module CarterdteSmtpFilter
  
  class SmtpServer < MidiSmtpServer::Smtpd
    
    def start
      @port = CarterdteSmtpFilter::Config::bind_port
      @host = CarterdteSmtpFilter::Config::bind_address
      @maxConnections = CarterdteSmtpFilter::Config::max_connections.to_i
      @logger = Logger.new('/dev/null') 
      super
    end
    
    def on_message_data_event(ctx)
      message = CarterdteSmtpFilter::Message.new(ctx[:message][:data])
      message.return_email
    end
    
  end
  
end