require 'test_helper'

class TestSpoolManager < Minitest::Test
  require 'sucker_punch/testing/inline'
  
  def setup
    @api_host = "api.dte.zboxapp.com"
    @api_url = CarterdteSmtpFilter::Config::api_url
    stub_request(:any, /#{@api_host}/).to_rack(FakeApi)
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    CarterdteSmtpFilter::Spool.directory_setup
    @directory = CarterdteSmtpFilter::Config::spool_directory
    @spool_manager = CarterdteSmtpFilter::SpoolManager.new
  end
  
  def teardown
    FileUtils.rm_r @directory if File.directory? @directory
  end

  def test_queued_files_should_return_an_array_queue_files
    assert_equal(Array, @spool_manager.queued_files.class)
  end
  
  def test_queued_files_elements_should_be_file_names_paths
    messages = []
    5.times do 
      message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
      message.enqueue
      messages << message
    end
    queued_files = @spool_manager.queued_files
    assert(queued_files.include?(messages.sample.queue_file), "Failure message.")
  end
  
  def test_resend_message_should_resend_the_message_and_erase_the_file
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message.enqueue
    queued_file = @spool_manager.queued_files.first
    r_message = @spool_manager.resend_message(queued_file)
    assert(r_message, "Failure message.")
    assert(!File.file?("#{message.queue_file}"), "Failure message.")
  end
  
  def test_resend_message_should_resend_the_message_and_erase_the_file
    message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
    message.enqueue
    queued_file = @spool_manager.queued_files.first
    r_message = @spool_manager.resend_message(queued_file)
    assert(r_message, "Failure message.")
    assert(!File.file?("#{message.queue_file}"), "Failure message.")
    assert(message.qid == r_message.qid, "Failure message.")
  end
  
  def test_sucker_punch_must_do_all_of_this
    messages = []
    5.times do 
      message = CarterdteSmtpFilter::Message.new File.open("./test/fixtures/mail_with_dte.eml", "rb").read
      message.enqueue
      messages << message
    end
    @spool_manager.async.perform
    assert_equal([], @spool_manager.queued_files)
  end


end