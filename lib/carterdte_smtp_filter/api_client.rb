module CarterdteSmtpFilter
  
  module ApiClient
    require 'rest-client'
    
    def self.logger
      CarterdteSmtpFilter.logger
    end
   
    def self.push(message)
      post({payload: message})  
    end
   
    def self.api_user
      CarterdteSmtpFilter::Config::api_user
    end
    
    def self.api_host
      CarterdteSmtpFilter::Config::api_host
    end
    
    def self.api_password
      CarterdteSmtpFilter::Config::api_password
    end
    
    def self.post(opts = {})
      url = opts[:url] || "https://#{CarterdteSmtpFilter::Config::api_host}/dtes"
      payload = opts[:payload] || {}
      begin
        # We make sure we are sending JSON
        JSON.parse payload
        resource = RestClient::Resource.new url, api_user, api_password
        return if CarterdteSmtpFilter::Config::testing
        logger.debug("Post #{payload} to #{url}") if CarterdteSmtpFilter::Config::debug
        response = resource.post payload, :content_type => :json, :accept => :json, :verify_ssl => OpenSSL::SSL::VERIFY_NONE
        logger.info("Api response #{response}")
      rescue Exception => e
        logger.error("#{e} - #{url}")
        response = false
      end
      response
    end
    
  end
  
end
