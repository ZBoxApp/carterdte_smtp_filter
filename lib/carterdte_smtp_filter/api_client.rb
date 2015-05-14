module CarterdteSmtpFilter
  
  class ApiClient
    require 'rest-client'
    include SuckerPunch::Job
    
    def logger
      CarterdteSmtpFilter.logger
    end
    
    def perform(message)
      logger.debug("Post #{payload} to #{url}") if CarterdteSmtpFilter::Config::debug
      push message
    end
   
    def push(message)
      return if CarterdteSmtpFilter::Config::testing
      post({payload: message})  
    end
   
    def api_user
      CarterdteSmtpFilter::Config::api_user
    end
    
    def api_host
      CarterdteSmtpFilter::Config::api_host
    end
    
    def api_password
      CarterdteSmtpFilter::Config::api_password
    end
    
    def post(url: nil, payload: nil)
      protocol = CarterdteSmtpFilter::Config::use_https ? "https" : "http"
      url ||= "#{protocol}://#{CarterdteSmtpFilter::Config::api_host}/messages"
      payload ||= {}
      begin
        # We make sure we are sending JSON
        JSON.parse payload
        resource = RestClient::Resource.new url, api_user, api_password
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
