module CarterdteSmtpFilter
  
  class Message
    
    TMP_MESSAGE_DIR = "/tmp/carterdte_smtp_filter"
    
    attr_accessor :raw_data, :return_qid, :email, :response, :dte, :qid
    
    def initialize(raw_data, envelope = nil, qid = nil)
      set_mail_defaults
      @raw_data = raw_data
      @email = parse_email(envelope)
      @logger = CarterdteSmtpFilter.logger
      @dte = extract_dte
      @qid = qid || generate_qid
      @return_qid = nil
    end
    
    def parse_email(envelope)
      email = Mail.read_from_string raw_data
      email.from = envelope[:from] unless envelope.nil?
      email.to = envelope[:to] unless envelope.nil?
      email
    end
    
    def queue_file
      queue_sub_dir = qid.split(//).first
      "#{Config::spool_directory}/#{queue_sub_dir}/#{qid}"
    end
    
    def enqueue
      @logger.info("Queueing message #{qid} - #{queue_file}")
      begin
        File.open("#{queue_file}", 'w') { |file| file.write(@raw_data) }  
      rescue Exception => e
        @logger.info("Could not save #{queue_file} - #{e}")
      end
    end
    
    def extract_dte
      return false unless @email.attachments.any?
      xml_attachments = @email.attachments.select {|m| File.extname(m.filename) == ".xml"}
      file = xml_attachments.any? ? xml_attachments.first : false
      return false unless file
      Dte.new file.body.decoded
    end
    
    def generate_qid
      (("A".."F").to_a + (0..9).to_a).sample(11).join("")
    end
    
    def has_dte?
      @dte ? true : false
    end
    
    def to_json
      JSON.generate(message: {
        to: @email.to.first,
        from: @email.from.first,
        qid: @qid,
        message_id: @email.message_id,
        cc: @email.cc,
        sent_date: @email.date.to_s,
        return_qid: @return_qid,
        rut_receptor: @dte.rut_receptor,
        rut_emisor: @dte.rut_emisor,
        dte_attributes: JSON.parse(@dte.to_json)
        })
    end
    
    def set_mail_defaults
      Mail.defaults do
        delivery_method :smtp, address: Config::return_host, port: Config::return_port, 
        return_response: true, enable_starttls_auto: false
      end
    end
    
    def extract_qid_from_response
      return false unless response.status == "250"
      # We suppose the string is like "250 2.0.0 Ok: queued as J5D0AWOR4F8\n"
      return false unless /Ok: queued as/.match response.string
      @return_qid = response.string.split(/\s+/).last
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