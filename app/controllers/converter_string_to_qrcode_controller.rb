class ConverterStringToQrcodeController < ApplicationController
  respond_to :xml, :json, :text
  
  def converte 
    if params[:string_converter].present?
      size_image = params[:size_image] ||= 200
      bit_depth_image = params[:bit_depth_image] ||= 1
      border_modules_image = params[:border_modules_image] ||= 4
      module_px_size_imagem = params[:module_px_size_imagem] ||= 6

      size_qrcode = params[:size_qrcode] ||= 4
      level_qrcode = params[:level_qrcode] ||= ":h"

      erroQrcode = ""

      begin
        qrcode = RQRCode::QRCode.new(params[:string_converter], size: size_qrcode, level: eval(level_qrcode)) #"http://dfe-portal.svrs.rs.gov.br/mdfe/QRCode?chMDFe=43181207312871000190580010000334041421310776&tpAmb=1

        png = qrcode.as_png(
          bit_depth: bit_depth_image,
          border_modules: border_modules_image,
          color_mode: ChunkyPNG::COLOR_GRAYSCALE,
          color: 'black',
          file: nil,
          fill: 'white',
          module_px_size: module_px_size_imagem,
          resize_exactly_to: false,
          resize_gte_to: false,
          size: size_image
        )
        b64File = Base64.encode64(png.to_s)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.imagens{
            xml.imagem{
              xml.conteudo b64File
              }
          }
        end
      rescue StandardError => error
        erroQrcode = error.message
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.erros{
            xml.erro{
              xml.conteudo erroQrcode
              }
          }
        end
      end

      send_data builder.to_xml, type: "text/xml", disposition: "inline"
    end
  end

  def exemplo
    puts "PAssou"
    exemplo = <<-HEREDOC
      string - the string you wish to encode
  
      size   - the size of the qrcode (default 4)
  
      level  - the error correction level, can be:
        * Level :l 7%  of code can be restored
        * Level :m 15% of code can be restored
        * Level :q 25% of code can be restored
        * Level :h 30% of code can be restored (default :h)
  
      mode   - the mode of the qrcode (defaults to alphanumeric or byte_8bit, depending on the input data):
        * :number
        * :alphanumeric
        * :byte_8bit
        * :kanji
      Example
  
      qrcode = RQRCodeCore::QRCode.new('hello world', size: 1, level: :m, mode: :alphanumeric)
    HEREDOC
    puts "PAssou2"
    puts exemplo
    send_data exemplo, type: "text/plain; charset=utf-8", disposition: "inline"
  end

end
