module CarterdteSmtpFilter
  
  class Message
    
    TMP_MESSAGE_DIR = "/tmp/carterdte_smtp_filter"
    
    attr_accessor :raw_data, :qid, :email, :response, :dte
    
    def initialize(raw_data)
      set_mail_defaults
      @raw_data = raw_data
      @email = Mail.read_from_string raw_data
      @logger = CarterdteSmtpFilter.logger
      @dte = extract_dte
      @qid = nil
    end
    
    def extract_dte
      return false unless @email.attachments.any?
      xml_attachments = @email.attachments.select {|m| m.sub_type == "xml"}
      file = xml_attachments.any? ? xml_attachments.first : false
      return false unless file
      CarterdteSmtpFilter::Dte.new file.body.decoded
    end
    
    def has_dte?
      @dte ? true : false
    end
    
    def to_json
      JSON.generate({
        to: @email.to,
        from: @email.from,
        message_id: @email.message_id,
        cc: @email.cc,
        sent_date: @email.date.to_s,
        qid: qid,
        dte_attributes: JSON.parse(@dte.to_json)
        })
    end
    
    def set_mail_defaults
      Mail.defaults do
        delivery_method :smtp, address: CarterdteSmtpFilter::Config::return_host, port: CarterdteSmtpFilter::Config::return_port, 
        return_response: true, enable_starttls_auto: false
      end
    end
    
    def extract_qid_from_response
      return false unless response.status == "250"
      # We suppose the string is like "250 2.0.0 Ok: queued as J5D0AWOR4F8\n"
      return false unless /Ok: queued as/.match response.string
      @qid = response.string.split(/\s+/).last
    end
    
    def save_tmp
      Dir.mkdir TMP_MESSAGE_DIR unless File.directory? TMP_MESSAGE_DIR
      @logger.info("Saving File #{TMP_MESSAGE_DIR}/#{@email.message_id}.eml")
      File.open("#{TMP_MESSAGE_DIR}/#{@email.message_id}.eml", 'w') { |file| file.write(@raw_data) }
    end
    
    def return_email
      @logger.info("Returning email <#{email.message_id}> to #{CarterdteSmtpFilter::Config::return_host}:#{CarterdteSmtpFilter::Config::return_port}")
      @response = email.deliver!
      extract_qid_from_response
    end
    
  end
  
end