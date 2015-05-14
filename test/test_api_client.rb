require 'test_helper'

class TestApiClient < Minitest::Test
  require 'sucker_punch/testing/inline'

  def setup
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    @api_host = CarterdteSmtpFilter::Config::api_host
    @api_url = "http://#{@api_host}"
    stub_request(:any, /#{@api_host}/).to_rack(FakeApi)
  end
  
  def test_push_should_return_false_if_message_is_not_json
    response = CarterdteSmtpFilter::ApiClient.new.push "hola"
    assert(!response, "Failure message.")
  end
    
  def test_check_fake_api_response
    user = CarterdteSmtpFilter::Config::api_user.gsub(/@/,"%40")
    response = RestClient.get "http://#{user}:#{CarterdteSmtpFilter::Config::api_password}@#{@api_host}/api/v1/"
    assert_equal("{api_version: 1}", response)
  end
  
  def test_post_should_workout_unauthorized
    response = CarterdteSmtpFilter::ApiClient.new.post({url: "#{@api_url}/api/v1/denied" })
    assert(!response, "Failure message.")
  end
  
  def test_post_should_workout_application_error
    response = CarterdteSmtpFilter::ApiClient.new.post({url: "#{@api_url}/api/v1/app_error" })
    assert(!response, "Failure message.")
  end
  
  def test_post_should_return_json
    hash = {dte_type: 33, msg_type: "envio"}
    message = JSON.generate hash
    response = CarterdteSmtpFilter::ApiClient.new.async.perform(message)
    new_hash = JSON.parse response
    assert_equal("123456", new_hash["id"])
    assert_equal(hash[:dte_type], new_hash["dte_type"])
  end
    
end