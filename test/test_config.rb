require 'test_helper'

class TestConfig < Minitest::Test
  
  def setup
    @config = YAML.load_file("./test/fixtures/config.yml")
    @config.each do |k,v|
      @config[k] = v.to_s
    end
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
  end
  
  def test_should_raise_not_file_if_file_not_exists
    assert_raises(Errno::ENOENT) { CarterdteSmtpFilter::Config.parse("/tmp/file") }
  end
  
  def test_should_return_config_values
    assert_equal(@config["bind_address"], CarterdteSmtpFilter::Config::bind_address)
    assert_equal(@config["return_host"], CarterdteSmtpFilter::Config::return_host)
    assert_equal(@config["return_port"], CarterdteSmtpFilter::Config::return_port)
    assert_equal(@config["api_user"], CarterdteSmtpFilter::Config::api_user)
    assert_equal(@config["api_password"], CarterdteSmtpFilter::Config::api_password)
    assert_equal(@config["api_url"], CarterdteSmtpFilter::Config::api_url)
    assert_equal(@config["log_file"], CarterdteSmtpFilter::Config::log_file)
  end
  
  def test_should_return_spool_dir_from_config_file_or_default_if_is_not_defined
    assert_equal("/var/spool/carter_smtp_filter", CarterdteSmtpFilter::Config::spool_dir)
  end
  
end