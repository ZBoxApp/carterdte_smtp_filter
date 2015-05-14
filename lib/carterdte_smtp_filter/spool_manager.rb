module CarterdteSmtpFilter
  
  class SpoolManager
    include SuckerPunch::Job
    
    def logger
      CarterdteSmtpFilter.logger
    end
    
    def perform()
      logger.info("Checking queued files...")
      queued_files.each do |qf|
        resend_message qf
      end
    end
    
    def resend_message(file_path)
      qid = queue_id file_path
      logger.info("Resending #{qid} - #{file_path}")
      message = CarterdteSmtpFilter::Message.new(File.read(file_path), qid)
      FileUtils.rm file_path
      CarterdteSmtpFilter::ApiClient.new.async.perform message
      message
    end
    
    def queued_files
      Dir.glob("#{Config::spool_directory}/[A-F0-9]/*")
    end
    
    def queue_id(file_path)
      File.basename file_path
    end
        
  end
  
end
    
    