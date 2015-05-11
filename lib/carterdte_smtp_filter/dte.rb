module CarterdteSmtpFilter
  
  class Dte
   
    VALID_NODES = %w(SetDTE Resultado)
    attr_accessor :dte_hash
   
    def initialize(xml_string)
      @dte_hash = XmlSimple.xml_in xml_string
      return false unless valid?
    end
    
    def valid?
      (dte_hash.keys & VALID_NODES).any?
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
      (dte_hash.keys & VALID_NODES).first
    end
    
    def root_node
      @dte_hash[root_name].first
    end
    
    def get_data(data)
      result = root_node["Caratula"].first[data].first if envio?
      result = root_node["RecepcionEnvio"].first[data].first if respuesta?
      return result.first if result.is_a? Array
      result
    end
    
    def msg_type
      return "respuesta" if root_name == "Resultado"
      return "envio" if root_name == "SetDTE"
    end
    
    def setdte_id
      return root_node["ID"] if envio?
      get_data "EnvioDTEID"
    end
    
    def rut_emisor
      get_data "RutEmisor"
    end
    
    def rut_receptor
      get_data "RutReceptor"
    end
    
    def dte_type
      return root_node["Caratula"].first["SubTotDTE"].first["TpoDTE"].first if envio?
      return root_node["RecepcionEnvio"].first["RecepcionDTE"].first["TipoDTE"].first if respuesta?
    end
    
    def fecha_emision
      time_stamp = get_data "TmstFirmaEnv" if envio?
      time_stamp = root_node["Caratula"].first["TmstFirmaResp"].first if respuesta?
      Time.parse(time_stamp).to_date
    end
    
    def fecha_recepcion
      return nil if envio?
      time_stamp = get_data "FchRecep"
      Time.parse(time_stamp).to_date
    end
    
  end
  
end
