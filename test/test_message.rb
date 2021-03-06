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
  
  def test_message_generate_qid_should_generate_a_valid_qid_in_hex_value
    raw_mail = File.open("./test/fixtures/mail.tmp", "rb").read
    message = CarterdteSmtpFilter::Message.new raw_mail
    qid = message.generate_qid
    assert(qid =~ /^[0-9A-F]+$/ , "Failure message.")
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
    message.return_email
    assert_equal(message.response.string.split(/\s+/).last, message.return_qid)  
  end
  
  def test_message_to_json_should_return_json_object_with_message_metada
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    assert(JSON.parse(message.to_json), "No JSON")
    json = JSON.parse(message.to_json)
    assert_equal(message.email.to.first, json["message"]["to"])
    assert_equal(message.email.from.first, json["message"]["from"])
    assert_equal(message.email.date.to_s, json["message"]["sent_date"])
    assert_equal("96529310-8", json["message"]["dte_attributes"]["rut_emisor"])
    assert_equal("96529310-8", json["message"]["rut_emisor"])
    assert(json["message"]["rut_receptor"], "No tiene receptor")
    assert(json["message"]["qid"])
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
  
  def test_save_tmp_should_make_tmp_dir_if_it_no_exist
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message.save_tmp
    assert(File.file?("/tmp/carterdte_smtp_filter/#{message.email.message_id}.eml"), "Failure message.")
  end
  
  def test_message_queue_file_should_return_the_full_path_of_the_queue_file
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    full_path = "#{CarterdteSmtpFilter::Config::spool_directory}/#{message.qid.split(//).first}/#{message.qid}"
    assert_equal(full_path, message.queue_file)
  end  
  
  def test_message_enqueue_must_create_a_file_with_qid_as_name
    CarterdteSmtpFilter::Spool.directory_setup
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message.enqueue
    assert(File.file?("#{message.queue_file}"), "Failure message.")
  end
  
  def test_should_work_with_corrupted_to_fields
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/to_in_brackets.eml", "rb").read
    message.return_email
    assert_equal(message.response.string.split(/\s+/).last, message.return_qid)  
  end
  
    
end