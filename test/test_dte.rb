require 'test_helper'

class TestDte < Minitest::Test
  
  def setup
    @resultado = File.open("./test/fixtures/acuse.xml", "rb")
    @envio = File.open("./test/fixtures/envio_dte_33.xml", "rb")
    @resultado_problema = File.open("./test/fixtures/acuse_2.xml", "rb")
    @dte_resultado = CarterdteSmtpFilter::Dte.new @resultado
    @dte_envio = CarterdteSmtpFilter::Dte.new @envio
    @dte_problema = CarterdteSmtpFilter::Dte.new @resultado_problema
  end
  
  def teardown
    
  end
  
  def test_should_only_parse_valid_dtes
    file = File.open("./test/fixtures/invalid_dte.xml", "rb")
    dte = CarterdteSmtpFilter::Dte.new file
    assert(!dte.valid?, "Should be false")
    assert(@dte_resultado.valid?, "Failure message.")
    assert(@dte_envio.valid?, "Failure message.")
    assert(@dte_problema.valid?, "Failure message.")
  end
  
  def test_root_should_return_the_root_element
    assert_equal("RespuestaDTE", @dte_resultado.root_name)
    assert_equal("RespuestaDTE", @dte_problema.root_name)
    assert_equal("EnvioDTE", @dte_envio.root_name)
  end
  
  def test_return_msg_type
    assert_equal("respuesta", @dte_resultado.msg_type)
    assert_equal("envio", @dte_envio.msg_type)
  end
  
  def test_return_setdte_id
    assert_equal("SETDTE94528000X33X7597817X94141763", @dte_resultado.setdte_id)
    assert_equal("SETDTE96529310X33X3152118X94141243", @dte_envio.setdte_id)
    assert_equal(nil, @dte_problema.setdte_id)
  end
  
  def test_return_folio
    assert_equal("7597817", @dte_resultado.folio)
    assert_equal("3152118", @dte_envio.folio)
    assert_equal("1970747", @dte_problema.folio)
  end
  
  def test_rut_emisor
    assert_equal("94528000-K", @dte_resultado.rut_emisor)
    assert_equal("96529310-8", @dte_envio.rut_emisor)
    assert_equal("96726970-0", @dte_problema.rut_emisor)
  end
  
  def test_rut_receptor
    assert_equal("81537600-5", @dte_resultado.rut_receptor)
    assert_equal("81201000-K", @dte_envio.rut_receptor)
    assert_equal("78481770-9", @dte_problema.rut_receptor)
  end
  
  def test_dte_type
    assert_equal("33", @dte_resultado.dte_type)
    assert_equal("33", @dte_envio.dte_type)
    assert_equal("33", @dte_problema.dte_type)
  end
  
  def test_dte_fecha_emision
    date_envio = Date.parse("2015-05-09")
    date_resultado = Date.parse("2015-05-11")
    date_problema = Date.parse("2015-05-11")
    assert_equal(date_resultado, @dte_resultado.fecha_emision)
    assert_equal(date_envio, @dte_envio.fecha_emision)
    assert_equal(date_problema, @dte_problema.fecha_emision)
  end
  
  def test_dte_fecha_recepcion
    date_resultado = Time.parse("2015-05-09T12:30:11").to_date
    assert_equal(date_resultado, @dte_resultado.fecha_recepcion)
    assert_equal(nil, @dte_problema.fecha_recepcion)
    assert_equal(nil, @dte_envio.fecha_recepcion)
  end
  
  def test_return_empty_json_if_no_valid
    file = File.open("./test/fixtures/invalid_dte.xml", "rb")
    dte = CarterdteSmtpFilter::Dte.new file
    json = JSON.parse dte.to_json
    assert_equal({}, json)
  end
  
  def test_return_json_object
    json = JSON.parse @dte_resultado.to_json
    assert_equal("81537600-5", json["rut_receptor"])
  end
  
  def test_return_json_even_for_fking_wrong_dtes
    assert(@dte_problema.rut_receptor, "rut_receptor")
    assert(@dte_problema.rut_emisor, "rut_emisor")
    assert(@dte_problema.msg_type, "msg_type")
    assert_nil(@dte_problema.setdte_id, "setdte_id")
    assert(@dte_problema.dte_type, "dte_type")
    assert(@dte_problema.folio, "folio")
    json = JSON.parse @dte_problema.to_json
    assert_equal("78481770-9", json["rut_receptor"])    
  end
  
end