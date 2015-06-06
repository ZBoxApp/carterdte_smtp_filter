module CarterdteSmtpFilter
  
  class SmtpServer < MidiSmtpServer::Smtpd
    
    def start
      @port = CarterdteSmtpFilter::Config::bind_port
      @host = CarterdteSmtpFilter::Config::bind_address
      @maxConnections = CarterdteSmtpFilter::Config::max_connections.to_i
      @logger = CarterdteSmtpFilter::Config::debug ? CarterdteSmtpFilter.logger : Logger.new("/dev/null")
      super
    end
    
    def carterdte_logger
      CarterdteSmtpFilter.logger
    end
    
    def on_message_data_event(ctx)
      message = CarterdteSmtpFilter::Message.new(ctx[:message][:data], ctx[:envelope])
      carterdte_logger.info("Processing message: #{message.qid}")
      # Save a copy when testing
      # /tmp/carterdte_smtp_filter/<message-id>
      message.save_tmp if CarterdteSmtpFilter::Config::testing

      # return the email back, and extract queue_id unless we are not 
      # working with Postfix
      begin
        message.return_email unless CarterdteSmtpFilter::Config::stand_alone
      rescue Exception => e
        # Esto pasa cuando colocan acento en el subject
        # y no avisan con el encoding que corresponde
        message.email.subject = message.email.subject.force_encoding('ISO-8859-1').encode('UTF-8')
        message.return_email unless CarterdteSmtpFilter::Config::stand_alone
      end
      
      # We send it to CarterDte App
      @logger.debug("Message DTE: #{message.dte}") if CarterdteSmtpFilter::Config::debug
      CarterdteSmtpFilter::ApiClient.new.async.perform message if message.has_dte?
    end
    
    # get event before Connection
    def on_connect_event(ctx)
      carterdte_logger.info("Connection from #{ctx[:server][:remote_ip]}")
    end

    # get event before DISONNECT
    def on_disconnect_event(ctx)
      carterdte_logger.info("Disconnect from #{ctx[:server][:remote_ip]}")
    end
    
  end
  
end