require "midi-smtp-server"
require "mail"
require 'json'
require 'xmlsimple'
require 'time'
require 'date'
require 'logger'
require 'rest-client'

require "carterdte_smtp_filter/version"
require "carterdte_smtp_filter/config"
require "carterdte_smtp_filter/smtp_server"
require "carterdte_smtp_filter/message"
require "carterdte_smtp_filter/dte"
require "carterdte_smtp_filter/api_client"

module CarterdteSmtpFilter
  
  def self.logger
    logger_dest = CarterdteSmtpFilter::Config::log_file.nil? ? "/dev/null" : CarterdteSmtpFilter::Config::log_file
    @logger = Logger.new(logger_dest)
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    @logger.formatter = proc { |severity, datetime, progname, msg| "#{datetime}: [#{severity}] #{msg.chomp}\n" }
    @logger
  end
  
end
