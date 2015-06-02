require 'test_helper'

class TestApiClient < Minitest::Test
  require 'sucker_punch/testing/inline'

  def setup
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    @api_host = "api.dte.zboxapp.com"
    @api_url = CarterdteSmtpFilter::Config::api_url
    stub_request(:any, /api.dte.zboxapp.com/).to_rack(FakeApi)
  end
  
  def test_push_should_return_false_if_message_is_not_json
    response = CarterdteSmtpFilter::ApiClient.new.async.perform "hola"
    assert(!response, "Failure message.")
  end
    
  def test_check_fake_api_response
    user = CarterdteSmtpFilter::Config::api_user.gsub(/@/,"%40")
    response = RestClient.get "http://#{user}:#{CarterdteSmtpFilter::Config::api_password}@#{@api_host}/api/v1/"
    assert_equal("{api_version: 1}", response)
  end
  
  def test_post_should_workout_unauthorized
    response = CarterdteSmtpFilter::ApiClient.new.post({url: "http://#{@api_host}/api/v1/denied" })
    assert(!response, "Failure message.")
  end
  
  def test_post_should_workout_application_error
    response = CarterdteSmtpFilter::ApiClient.new.post({url: "http://#{@api_host}/api/v1/app_error" })
    assert(!response, "Failure message.")
  end
  
  def test_post_should_return_json
    raw_mail = File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message = CarterdteSmtpFilter::Message.new raw_mail
    response = CarterdteSmtpFilter::ApiClient.new.async.perform(message)
    new_hash = JSON.parse response
    # assert_equal("123456", new_hash["id"])
    # assert_equal(hash[:dte_type], new_hash["dte_type"])
  end
  
  def test_post_duplicated_message_should_return_true
    response = CarterdteSmtpFilter::ApiClient.new.post({url: "http://#{@api_host}/messages/uniq" })
    assert(response, "Failure message.")
  end
  
  def test_should_save_queue_file_if_negative_response
    CarterdteSmtpFilter::Spool.directory_setup
    raw_mail = File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message = CarterdteSmtpFilter::Message.new raw_mail
    CarterdteSmtpFilter::ApiClient.new.push(message, "http://#{@api_host}/api/v1/app_error")
    assert(File.file?("#{message.queue_file}"), "Failure message.")
  end
  
    
end