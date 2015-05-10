require "carterdte_smtp_filter"
require 'pp'

require 'minitest/autorun'
require 'minitest/reporters' # requires the gem

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new # spec-like progress

# Only log Celluloid errors
#Celluloid.logger.level = Logger::ERROR


#CarterDteSmtp::Config.parse("./test/fixtures/config.yml")

def check_imap()
  require "mail"
  Mail.defaults do
    retriever_method :imap, address: "localhost", port: 143,  user_name: "carterdte", password: "123456"
  end
  
  emails = Mail.find keys: ['NOT', 'SEEN']
  emails.first
  
end


class Enviacorreo  
  attr_accessor :to, :from, :body, :subject, :attachment_path, :server, :port
  
  def initialize(to: "carterdte@example.com", from: "dte@itlinux.cl", body: "Cuerpo correo", subject: "DTE", attachment_path: false, server: "localhost", port: 2025)
    @to = to
    @from = from
    @body = body
    @subject = subject
    @attachment_path = attachment_path
    @server = server
    @port = port
  end
  
  def send
    message.deliver!
  end
  
  def message
    smtp_conn = smtp_options
    Mail.defaults do
      delivery_method :smtp_connection, { :connection => smtp_conn.start }
    end
    mail = Mail.new(
       from:     @from,
       to:       @to,
       subject:  @subject,
       body:     @body
    )
    mail.add_file @attachment_path if @attachment_path
    mail
  end
  
  def smtp_options
    smtp = Net::SMTP.new(@server, @port)
    smtp.read_timeout = 2
    smtp.open_timeout = 2
    smtp
  end
  
end