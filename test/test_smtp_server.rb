require 'test_helper'

class TestSmtpServer < Minitest::Test
  
  def setup
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    @api_host = CarterdteSmtpFilter::Config::api_host
    @api_url = "http://#{@api_host}"
    stub_request(:any, /#{@api_host}/).to_rack(FakeApi)
    @server = CarterdteSmtpFilter::SmtpServer.new()
    @server.start
    @return_stmp = ReturnSmtp.new()
    @return_stmp.start
  end
  
  def teardown
    @server.shutdown
    sleep 2 unless @server.connections == 0
    @server.stop
    @return_stmp.shutdown
    @return_stmp.stop
  end
  
  def test_carterdte_smtp_filter_should_accept_mail
    mail = Enviacorreo.new(port: CarterdteSmtpFilter::Config::bind_port)
    assert(mail.send, "Failure message.")
  end

  def test_should_return_email_to_postfix
    mail = Enviacorreo.new(port: CarterdteSmtpFilter::Config::bind_port)
    mail.send
    return_email = Mail.read "./test/tmp/returnmail"
    assert_equal("DTE", return_email.subject)
  end
  
  def test_should_accept_email_with_attachments
    xml_file = "./test/fixtures/envio_dte_33.xml"
    mail = Enviacorreo.new(port: CarterdteSmtpFilter::Config::bind_port, subject: "DTE Attachment", attachment_path: xml_file)
    assert(mail.send, "Failure message.")
  end
    
end