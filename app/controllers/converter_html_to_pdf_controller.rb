class ConverterHtmlToPdfController < ApplicationController
  respond_to :xml, :json
    
  def converte
    if params[:documento].present?
      v_pag_size = params[:page_size] || "A4"
      v_zoom = params[:zoom] || 1.0
      v_margin_top = params[:margin_top] || '0.39in'

      arquivo_html = Base64.decode64(params[:documento])
      vEncodeSalvo = Encoding.default_external

      Encoding.default_external = eval("Encoding::#{arquivo_html.encoding.name.gsub('-','_')}")

      kit = PDFKit.new(arquivo_html,
                       page_size: v_pag_size, 
                       zoom: v_zoom,
                       margin_top: v_margin_top)

      pdf = kit.to_pdf
     
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.arquivos{
          xml.arquivo_pdf{
            xml.conteudo Base64.encode64(pdf)
          }
        }
      end
      send_data builder.to_xml, type: "text/xml", disposition: "inline"
      Encoding.default_external = vEncodeSalvo
    end
  end
end