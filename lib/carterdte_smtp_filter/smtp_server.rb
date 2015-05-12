module CarterdteSmtpFilter
  
  class SmtpServer < MidiSmtpServer::Smtpd
    
    def start
      @port = CarterdteSmtpFilter::Config::bind_port
      @host = CarterdteSmtpFilter::Config::bind_address
      @maxConnections = CarterdteSmtpFilter::Config::max_connections.to_i
      @logger = Logger.new("/dev/null")
      super
    end
    
    def on_message_data_event(ctx)
      message = CarterdteSmtpFilter::Message.new(ctx[:message][:data])
      # return the email back, and extract queue_id unless we are not 
      # working with Postfix
      message.process unless CarterdteSmtpFilter::Config::stand_alone
      CarterdteSmtpFilter::ApiClient.push message.to_json if message.has_dte?
    end
    
    # get event before Connection
    def on_connect_event(ctx)
      CarterdteSmtpFilter.logger.info("Connection from #{ctx[:server][:remote_ip]}")
    end

    # get event before DISONNECT
    def on_disconnect_event(ctx)
      CarterdteSmtpFilter.logger.info("Disconnect from #{ctx[:server][:remote_ip]}")
    end
    
  end
  
end