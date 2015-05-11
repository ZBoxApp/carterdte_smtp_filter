require 'test_helper'

class TestConfig < Minitest::Test
  
  def test_should_raise_not_file_if_file_not_exists
    assert_raises(Errno::ENOENT) { CarterdteSmtpFilter::Config.parse("/tmp/file") }
  end
  
  def test_should_return_config_values
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    assert_equal("127.0.0.1", CarterdteSmtpFilter::Config::bind_address)
    assert_equal("127.0.0.1", CarterdteSmtpFilter::Config::return_host)
    assert_equal("30025", CarterdteSmtpFilter::Config::return_port)
    assert_equal("pbruna@example.com", CarterdteSmtpFilter::Config::api_user)
    assert_equal("123456", CarterdteSmtpFilter::Config::api_password)
    assert_equal("api.dte.zboxapp.com", CarterdteSmtpFilter::Config::api_host)
    assert_equal("./test/tmp/carterdte_smtp_filter.log", CarterdteSmtpFilter::Config::log_file)
  end
  
end