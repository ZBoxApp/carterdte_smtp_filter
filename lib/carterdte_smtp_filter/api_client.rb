module CarterdteSmtpFilter
  
  module ApiClient
    require 'rest-client'
    
    def self.logger
      CarterdteSmtpFilter.logger
    end
   
    def self.push(message)
      response = post({payload: message})  
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
        logger.info("Post #{payload} to #{url}")
        resource = RestClient::Resource.new url, api_user, api_password
        response = resource.post payload, :content_type => :json, :accept => :json
        #response = restclient("post", url, api_user, api_password, api_host, payload).execute
      rescue Exception => e
        logger.error("#{e} - #{url}")
        response = false
      end
      response
    end
    
    def self.restclient(method = "get", url = nil, user = nil, password = nil, payload = {}, headers = nil)
      headers ||= { :accept => :json, :content_type => :json }
      RestClient::Request.new(method: method, url: url, user: user, password: password, headers: headers, payload: payload)
    end
    
  end
  
end
