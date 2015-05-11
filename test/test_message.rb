require 'test_helper'

class TestMessage < Minitest::Test
  
  def setup
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
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
  
  def test_message_should_save_server_response_when_returning_email
    raw_mail = File.open("./test/fixtures/mail.tmp", "rb").read
    message = CarterdteSmtpFilter::Message.new raw_mail
    response = message.return_email
    assert(Net::SMTP::Response == message.response.class, "Response should be a SMTP Response")
  end
  
  def test_message_should_save_server_queueid_response_if_any
    raw_mail = File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message = CarterdteSmtpFilter::Message.new raw_mail
    message.process
    assert_equal(message.response.string.split(/\s+/).last, message.qid)  
  end
  
  def test_message_to_json_should_return_json_object_with_message_metada
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    assert(JSON.parse(message.to_json), "No JSON")
    json = JSON.parse(message.to_json)
    assert_equal(message.email.to, json["to"])
    assert_equal(message.email.from, json["from"])
    assert_equal(message.email.date.to_s, json["date"])
  end

  def test_extract_dte_should_return_false_if_no_attachments
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail.tmp", "rb").read
    assert(!message.extract_dte, "Failure message.")
  end
  
  def test_extract_dte_should_return_false_if_no_dte_attachments
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/email_with_attachment_no_dte.eml", "rb").read
    assert(!message.extract_dte, "Failure message.")
  end
  
  def test_extract_dte_should_return_mail_part_with_xml_file
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_multiple_attachments.eml", "rb").read
    assert(message.dte, "Failure message.")
  end

  
  def test_message_dte_should_be_a_dte_object
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    assert_equal(CarterdteSmtpFilter::Dte, message.dte.class)
  end
  
    
end