require "carterdte_smtp_filter"
require 'pp'
require 'time'
require 'date'

require 'minitest/autorun'
require 'minitest/reporters' # requires the gem
require 'webmock/minitest'

require 'fake_api'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new # spec-like progress

# Only log Celluloid errors
Celluloid.logger.level = Logger::ERROR


#CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")

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

class ReturnSmtp < MidiSmtpServer::Smtpd

  attr_accessor :mail

  def start
    @logger = Logger.new('/dev/null')
    @port = CarterdteSmtpFilter::Config::return_port
    @host = CarterdteSmtpFilter::Config::return_host
    super
  end

  def on_message_data_event(ctx)
    File.open("./test/tmp/returnmail", "w") {|file| file.write ctx[:message][:data]}
  end
  
  def process_line(line)
        # check wether in data or command mode
        if Thread.current[:cmd_sequence] != :CMD_DATA

          # Handle specific messages from the client
          case line
        
          when (/^(HELO|EHLO)(\s+.*)?$/i)
            # HELO/EHLO
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 504 Command parameter not implemented
            # 521 <domain> does not accept mail [rfc1846]
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_HELO
            # handle command
            @cmd_data = line.gsub(/^(HELO|EHLO)\ /i, '').strip
            # call event to handle data
            on_helo_event(Thread.current[:ctx], @cmd_data)
            # if no error raised, append to message hash
            Thread.current[:ctx][:server][:helo] = @cmd_data
            # set sequence state as RSET
            Thread.current[:cmd_sequence] = :CMD_RSET
            # reply ok
            return "250 OK"

          when (/^NOOP\s*$/i)
            # NOOP
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 500 Syntax error, command unrecognised
            return "250 OK"
        
          when (/^RSET\s*$/i)
            # RSET
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] == :CMD_HELO
            # handle command
            reset_ctx
            return "250 OK"
        
          when (/^QUIT\s*$/i)
            # QUIT
            # 221 <domain> Service closing transmission channel
            # 500 Syntax error, command unrecognised
            Thread.current[:cmd_sequence] = :CMD_QUIT
            return ""
        
          when (/^MAIL FROM\:/i)
            # MAIL
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 451 Requested action aborted: local error in processing
            # 452 Requested action not taken: insufficient system storage
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 552 Requested mail action aborted: exceeded storage allocation
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_RSET
            # handle command
            @cmd_data = line.gsub(/^MAIL FROM\:/i, '').strip
            # call event to handle data
            if return_value = on_mail_from_event(Thread.current[:ctx], @cmd_data)
              # overwrite data with returned value
              @cmd_data = return_value
            end
            # if no error raised, append to message hash
            Thread.current[:ctx][:envelope][:from] = @cmd_data
            # set sequence state
            Thread.current[:cmd_sequence] = :CMD_MAIL
            # reply ok
            return "250 OK"
        
          when (/^RCPT TO\:/i)
            # RCPT
            # 250 Requested mail action okay, completed
            # 251 User not local; will forward to <forward-path>
            # 421 <domain> Service not available, closing transmission channel
            # 450 Requested mail action not taken: mailbox unavailable
            # 451 Requested action aborted: local error in processing
            # 452 Requested action not taken: insufficient system storage
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 503 Bad sequence of commands
            # 521 <domain> does not accept mail [rfc1846]
            # 550 Requested action not taken: mailbox unavailable
            # 551 User not local; please try <forward-path>
            # 552 Requested mail action aborted: exceeded storage allocation
            # 553 Requested action not taken: mailbox name not allowed
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if ![ :CMD_MAIL, :CMD_RCPT ].include?(Thread.current[:cmd_sequence])
            # handle command
            @cmd_data = line.gsub(/^RCPT TO\:/i, '').strip
            # call event to handle data
            if return_value = on_rcpt_to_event(Thread.current[:ctx], @cmd_data)
              # overwrite data with returned value
              @cmd_data = return_value
            end
            # if no error raised, append to message hash
            Thread.current[:ctx][:envelope][:to] << @cmd_data
            # set sequence state
            Thread.current[:cmd_sequence] = :CMD_RCPT
            # reply ok
            return "250 OK"
        
          when (/^DATA\s*$/i)
            # DATA
            # 354 Start mail input; end with <CRLF>.<CRLF>
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel received data
            # 451 Requested action aborted: local error in processing
            # 452 Requested action not taken: insufficient system storage
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 503 Bad sequence of commands
            # 552 Requested mail action aborted: exceeded storage allocation
            # 554 Transaction failed
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_RCPT
            # handle command
            # set sequence state
            Thread.current[:cmd_sequence] = :CMD_DATA
            # reply ok / proceed with message data
            return "354 Enter message, ending with \".\" on a line by itself"
        
          else
            # If we somehow get to this point then
            # we have encountered an error
            raise Smtpd500Exception

        end
        
        else
          # If we are in data mode and the entire message consists
          # solely of a period on a line by itself then we
          # are being told to exit data mode
          if (line.chomp =~ /^\.$/)
            # append last chars to message data
            Thread.current[:ctx][:message][:data] += line
            # remove ending line .
            Thread.current[:ctx][:message][:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
            # save delivered time
            Thread.current[:ctx][:message][:delivered] = Time.now.utc
            # save bytesize of message data
            Thread.current[:ctx][:message][:bytesize] = Thread.current[:ctx][:message][:data].bytesize
            # call event
            begin
              on_message_data_event(Thread.current[:ctx])
              array = (0..9).to_a + ("A".."F").to_a
              return "250 2.0.0 Ok: queued as #{array.sample(11).join("")}"
          
            # test for SmtpdException 
            rescue SmtpdException
              # just re-raise exception set by app
              raise
          
            # test all other Exceptions
            rescue Exception => e
              # send correct aborted message to smtp dialog
              raise Smtpd451Exception.new("#{e}")

            ensure
              # always start with empty values after finishing incoming message
              # and rset command sequence
              reset_ctx
            end
        
          else
            # If we are in date mode then we need to add
            # the new data to the message
            Thread.current[:ctx][:message][:data] += line
            return ""
            # command sequence state will stay on :CMD_DATA

          end

        end
      end

end