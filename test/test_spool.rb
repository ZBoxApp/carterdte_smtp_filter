require 'test_helper'

class TestSpool < Minitest::Test
  
  def setup
    CarterdteSmtpFilter::Config.parse("./test/fixtures/config.yml")
    @directory = CarterdteSmtpFilter::Config::spool_directory
  end
  
  def teardown
    FileUtils.rm_r @directory if File.directory? @directory
  end
  
  def test_should_create_spool_directory
    CarterdteSmtpFilter::Spool.build_spool
    assert(File.directory?(@directory), "No se creo el spool")
  end
  
  def test_should_not_creatre_the_spool_directory_if_already_exists
    FileUtils.mkdir_p @directory
    assert(CarterdteSmtpFilter::Spool.build_spool)
  end
  
  def test_should_create_the_inside_structure
    CarterdteSmtpFilter::Spool.build_spool_structure
    (("A".."F").to_a + (0..9).to_a).each do |d|
      base_dir = "#{@directory}/#{d.to_s}"
      assert(File.directory?(base_dir), "#{base_dir} no dir" )
    end
  end
  
  def test_setup_spool_should_do_everything
    CarterdteSmtpFilter::Spool.directory_setup
    (("A".."F").to_a + (0..9).to_a).each do |d|
      base_dir = "#{@directory}/#{d.to_s}"
      assert(File.directory?(base_dir), "#{base_dir} no dir" )
    end
  end
  
  
end