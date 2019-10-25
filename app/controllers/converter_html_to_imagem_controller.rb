class ConverterHtmlToImagemController < ApplicationController
  respond_to :xml, :json

  def converte
    if params[:documento].present?
      vEncodeSalvo = Encoding.default_external
      vArquivo = Base64.decode64(params[:documento]) #.force_encoding("UTF-8") #.encode("windows-1252") #.encode #.force_encoding(vEncoder)

      Encoding.default_external = eval("Encoding::#{vArquivo.encoding.name.gsub('-','_')}")

      vWidthPadrao = 600
      vWidthPadrao = vWidthPadrao * params[:scale].to_f if params[:scale].present?
      vQuality = params[:quality] ||= 80
      vFormat = params[:format].downcase ||= "jpg"

      kit = IMGKit.new(vArquivo, :quality => vQuality, :width => vWidthPadrao) #File.open(vArquivo"html_gerado.html", "rb").read
      img = kit.to_img(vFormat.to_sym)

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.imagens{
            xml.imagem{
            xml.conteudo Base64.encode64(img)
            }
        }
      end

      send_data builder.to_xml, type: "text/xml", disposition: "inline"
      Encoding.default_external = vEncodeSalvo
    end
  end


  def exemplo

    exemplo= <<-EOF
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
    EOF

    send_data exemplo, disposition: "inline"
  end

end