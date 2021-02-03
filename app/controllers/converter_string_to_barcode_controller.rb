class ConverterStringToBarcodeController < ApplicationController

  def converte
   require 'barby'
   require 'barby/barcode/code_128'
   require 'barby/outputter/png_outputter'


    if params[:string_converter].present?
      heigth = params[:height].to_i ||= 60
      margin = params[:margin].to_i ||= 5
      xdim = params[:xdim].to_i ||= 1
      tipoC = params[:tipo_code] ||=Barby::Code128
      tipo_code = "#{tipoC.classify.constantize}.new(\"#{params[:string_converter]}\")"
      barcode = eval(tipo_code)
      b64file = Base64.encode64(barcode.to_png(:height => heigth, :xdim => xdim, :margin => margin).to_s)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.imagens{
          xml.imagem{
            xml.conteudo b64file
            }
        }
      end
      send_data builder.to_xml, type: "text/xml", disposition: "inline"
    end
  end
end
