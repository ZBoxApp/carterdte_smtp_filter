module CarterdteSmtpFilter
  
  class Message
    
    attr_accessor :raw_data, :qid, :email, :response, :dte
    
    def initialize(raw_data)
      set_mail_defaults
      @raw_data = raw_data
      @email = Mail.read_from_string raw_data
      @dte = extract_dte
    end
    
    def extract_dte
      return false unless @email.attachments.any?
      file = @email.attachments.select {|m| m.sub_type == "xml"}.first
      return false unless file
      CarterdteSmtpFilter::Dte.new file.body.decoded
    end
    
    def process
      return_email
      return unless has_dte?
      extract_qid_from_response
    end
    
    def has_dte?
      @dte ? true : false
    end
    
    def to_json
      JSON.generate({
        to: @email.to,
        from: @email.from,
        cc: @email.cc,
        date: @email.date.to_s,
        qid: qid,
        dte: JSON.parse(@dte.to_json)
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
    
    def return_email
      @response = email.deliver!
    end
    
  end
  
end