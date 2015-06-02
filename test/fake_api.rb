require 'sinatra/base'
require 'pp'

class FakeApi < Sinatra::Base

  # Gdexpress uses a header nanmed AuthKey with the API Key
  CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
  API_USER = CarterdteSmtpFilter::Config::api_user
  API_PASSWORD = CarterdteSmtpFilter::Config::api_password
  
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username.gsub(/%40/,"@") == API_USER && password == API_PASSWORD
  end
  
  get '/api/v1/' do
    content_type :json
    status 200
    "{api_version: 1}"
  end
  
  post '/api/v1/denied' do
    return access_denied
  end
  
  post '/api/v1/app_error' do
    codes = (500..511).to_a
    codes = codes + [598, 599]
    content_type :json
    status codes.sample
  end

  
  post '/dte_messages' do
    request.body.rewind
    data = JSON.parse request.body.read
    status = 200
    data["id"] = "123456"
    JSON.generate(data)
  end
  
  post '/messages/uniq' do
    status 422
    ""
  end
  
  private

  def authenticate(env)
    return true if env["HTTP_AUTHKEY"] == AUTH_KEY
    false
  end

  def access_denied
    content_type :json
    status 403
  end

  def api_call_failed
    content_type :xml
    status 200
    File.open(File.dirname(__FILE__) + '/fixtures/' + "failled_api_call.xml", 'rb').read
  end

  def xml_response(response_code, method, folio)
    content_type :xml
    status response_code
    file_name = "#{folio}_#{GDE_METHODS[method]}.xml"
    begin
      File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
    rescue Errno::ENOENT => e
      File.open(File.dirname(__FILE__) + '/fixtures/' + "not_found.xml", 'rb').read
    end
  end
end