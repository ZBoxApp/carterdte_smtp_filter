module CarterdteSmtpFilter
  
  class ApiClient
    require 'rest-client'
    include SuckerPunch::Job
    
    def logger
      CarterdteSmtpFilter.logger
    end
    
    def perform(message)
      push message if valid?(message)
    end
   
    def push(message, url = nil)
      response = post({payload: message.to_json, url: url})
      return response if response
      message.enqueue
    end
    
    def valid?(message)
      return false if CarterdteSmtpFilter::Config::testing
      is_json?(message.to_json)
    end
    
    def is_json?(message)
      begin
        result = JSON.parse message
      rescue Exception => e
        result = false
      end
      result.is_a? Hash
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
    
    def post(opts = {})
      url = opts[:url] || CarterdteSmtpFilter::Config::api_url
      payload = opts[:payload] || {}
      begin
        resource = RestClient::Resource.new url, api_user, api_password
        logger.debug("Post #{payload} to #{url}") if CarterdteSmtpFilter::Config::debug
        response = resource.post payload, :content_type => :json, :accept => :json, :verify_ssl => OpenSSL::SSL::VERIFY_NONE
        logger.debug("Api response #{response}")
      rescue Exception => e
        logger.error("#{e} #{e.http_code} - #{url}")
        
        # Esto significa que se trato de enviar un mensaje duplicado
        # Por lo tanto no se debe considerar como un fallo de envio
        response = e.http_code == 422 ? true : false
      end
      response
    end
    
  end
  
end
