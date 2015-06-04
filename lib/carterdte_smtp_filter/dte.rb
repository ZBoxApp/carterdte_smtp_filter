module CarterdteSmtpFilter
  
  class Dte
   
    VALID_NODES = %w(EnvioDTE RespuestaDTE)
    attr_accessor :dte_xml
   
    def initialize(xml_string)
      @dte_xml = Nokogiri::XML xml_string
      return false unless valid?
    end
    
    def valid?
      VALID_NODES.include? root_name
    end
    
    def envio?
      msg_type == "envio"
    end
    
    def respuesta?
      msg_type == "respuesta"
    end
    
    def to_json
      return JSON.generate({}) unless valid?
      JSON.generate({
        folio: folio,
        rut_receptor: rut_receptor,
        rut_emisor: rut_emisor,
        msg_type: msg_type,
        setdte_id: setdte_id,
        dte_type: dte_type,
        fecha_emision: fecha_emision,
        fecha_recepcion: fecha_recepcion
      })
    end
    
    def root_name
      dte_xml.root.name
    end
    
    def root_node
      @dte_xml[root_name].first
    end
    
    def get_data(data)
      el = @dte_xml.at_css(data)
      return nil if el.nil?
      el.text
    end
    
    def msg_type
      return "respuesta" if root_name == "RespuestaDTE"
      return "envio" if root_name == "EnvioDTE"
    end
    
    def setdte_id
      return @dte_xml.at_css("SetDTE").attribute("ID").value if envio?
      value = @dte_xml.at_css("EnvioDTEID")
      value.nil? ? nil : value.text
    end
    
    def rut_emisor
      get_data "RUTEmisor"
    end
    
    def rut_receptor
      get_data "RUTRecep"
    end
    
    def dte_type
      get_data "TipoDTE"
    end
    
    def folio
      get_data "Folio"
    end
    
    def fecha_emision
      time_stamp = get_data "FchEmis"
      time_stamp.nil? ? nil : Time.parse(time_stamp).to_date
    end
    
    def fecha_recepcion
      return nil if envio?
      time_stamp = @dte_xml.at_css "FchRecep"
      time_stamp.nil? ? nil : Time.parse(time_stamp.text).to_date
    end
    
  end
  
end
