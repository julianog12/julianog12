class ConverterPdfToImagemController < ApplicationController
  
  def converte
    if params[:documento].present?
      vQuality = 90
      vDensity = "250x250"
      vScale = 0.70
      vFormat = "JPG"
      vQuality = params[:quality] if params[:quality].present?
      vDensity = params[:density] if params[:density].present?
      vFormat = params[:format]  if params[:format].present?
      vScale = params[:scale].to_f  if params[:scale].present?
      vTime = Time.now.strftime("%d%m%Y%H%M%S")
      vNomeArquivo = "FilePdf_#{vTime}.pdf"
      vNomeArqImg = "Imagem_#{vTime}.#{vFormat}"
        
      vArquivo = Base64.decode64(params[:documento]).force_encoding("UTF-8").encode
      vFile = File.new(vNomeArquivo, "w")
      vFile.write(vArquivo)
      vFile.close
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.imagens{
          pdf = Magick::ImageList.new(vNomeArquivo) do
            self.quality = vQuality
            self.density = vDensity
            self.format = vFormat
            self.interlace = Magick::NoInterlace
          end
          pdf.each_with_index do |img, vCont|
            if params[:alpha_type].present?
              vEnum = {parametro: params[:alpha_type]}
              img.alpha(eval(vEnum[:parametro]))
            end
            img.scale(vScale) if params[:scale].present?
            img.write("#{vCont}_#{vNomeArqImg}")
            img_64     = Base64.encode64(File.open("#{vCont}_#{vNomeArqImg}", "rb").read)
            xml.imagem{
              xml.conteudo img_64
            }
            if File.exists?("#{vCont}_#{vNomeArqImg}")
              File.delete("#{vCont}_#{vNomeArqImg}")
            end
          end
        }
      end
      if File.exists?(vNomeArquivo)
        File.delete(vNomeArquivo)
      end
      send_data builder.to_xml, type: "text/xml", disposition: "inline"
    end
  end
end