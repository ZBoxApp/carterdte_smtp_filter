require 'test_helper'

class TestSmtpServer < Minitest::Test
  
  def setup
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    @server = CarterdteSmtpFilter::SmtpServer.new
    @server.start
  end
  
  def test_carterdte_smtp_filter_should_accept_mail
    mail = Enviacorreo.new(port: CarterdteSmtpFilter::Config::bind_port)
    assert(mail.send, "Failure message.")
  end
    
end