class ConverterXlsxToCsvController < ApplicationController
  ActionController::Parameters.permit_all_parameters = true

  def converte 
    if params[:docto_xlsx].present?
      vEncodeSalvo = Encoding.default_external
      arq_b64 = params[:docto_xlsx]

      arquivo_xlsx = Base64.decode64(arq_b64).force_encoding("UTF-8").encode

      nome_arquivo_xlsx = "arquivo_xlsx_#{Time.now.strftime('%d%m%Y%H%M%S')}"

      a = File.new("./#{nome_arquivo_xlsx}.xlsx", "w")
      a.write arquivo_xlsx
      a.close

      xlsx = Roo::Excelx.new("./#{nome_arquivo_xlsx}.xlsx") #, :zip, :warning)

      arquivo_csv = xlsx.to_csv

      arquivo_csv = arquivo_csv.gsub(/\n/, "\r\n")

      a = File.new("./#{nome_arquivo_xlsx}.csv", "w")
      a.write arquivo_csv
      a.close

      arq_b64 = Base64.encode64(File.open("./#{nome_arquivo_xlsx}.csv", "r:UTF-8", &:read))
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.arquivos{
          xml.arquivo_csv{
            xml.conteudo arq_b64
          }
        }
       end
       #File.delete(nome_arquivo_xlsx)
       send_data builder.to_xml, type: "text/xml", disposition: "inline"
       Encoding.default_external = vEncodeSalvo
    end
  end

end
