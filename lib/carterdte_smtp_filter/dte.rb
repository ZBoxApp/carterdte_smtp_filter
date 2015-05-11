module CarterdteSmtpFilter
  
  class Dte
   
    def initialize(xml_string)
      @xml = XmlSimple.xml_in xml_string
      pp @xml
    end
    
    def to_json
      
    end
    
  end
  
end
