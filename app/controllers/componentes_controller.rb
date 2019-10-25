class ComponentesController < ApplicationController
  respond_to :json, :html

  def index
    @campos = []
    @keywords = ""
    @componentes = []
   
    # Verifica se o usuário entrou com keywords
    if params[:cd_empresa].present?
      @cd_empresa = params[:cd_empresa]
    end
    if params[:fields].present?
      @campos = params[:fields].map{|n| n.to_sym}
   end
    if params[:keywords].present?
      # Diz ao elastickick para pesquisar as keyrwords nos campos name e description
      @keywords = params[:keywords]
      if @campos.nil?
        @componentes = Componente.search(params[:keywords], 
                                        aggs: {store_id: {limit: 15000}},
                                        operator: params[:operator_field],
                                        where: { cd_empresa: params[:cd_empresa]},
                                        match: params[:match_field].to_sym,
                                        misspellings: false)
                                        #order: {"id" => "desc"},
      else
        @componentes = Componente.search(params[:keywords], 
                                        fields: @campos, 
                                        aggs: {store_id: {limit: 15000}},
                                        operator: params[:operator_field],
                                        where: {cd_empresa: params[:cd_empresa]}, 
                                        misspellings: false,
                                        match: params[:match_field].to_sym)
                                        #order: {"id" => "desc"},
      end
      respond_with(@componentes)
    end
  end
  
  def conversor
    
    if params[:documento].present?

      if params[:tipo_conversao] == "pdf_para_imagem"
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

      elsif params[:tipo_conversao] == "html_para_imagem"

         vEncodeSalvo = Encoding.default_external
         vArquivo = Base64.decode64(params[:documento]) #.force_encoding("UTF-8") #.encode("windows-1252") #.encode #.force_encoding(vEncoder)
         Encoding.default_external = eval("Encoding::#{vArquivo.encoding.name.gsub('-','_')}")
         vWidthPadrao = 600
   	     vQuality = 80
         vFormat = "JPG".downcase
         vQuality = params[:quality] if params[:quality].present?
         vFormat = params[:format].downcase  if params[:format].present?
         vWidthPadrao = vWidthPadrao * params[:scale].to_f if params[:scale].present?
         vTime = Time.now.strftime("%d%m%Y%H%M%S")
         vNomeArquivo = "FileHtml_#{vTime}.html"
         kit = IMGKit.new(vArquivo, :quality => vQuality, :width => vWidthPadrao)
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
  end
 
  # POST /componentes
  # POST /componentes.json
  def create
    @componente = Componente.new(componente_params)

    begin
     @componente.save #if
       #render body: nil
       #end
    rescue ActiveRecord::RecordNotUnique
      logger.info "ERROGRAVARCOMPONENTEDUPLICADO"
    end
    render body: nil    
  end

  def destroy
    begin
      Componente.where("nome = ? and cd_empresa = ?", "#{params[:id]}", "#{params[:cd_empresa]}").each do |reg|
        reg.delete
        Componente.searchkick_index.remove(reg)
      end
    rescue
      nil
    end
  end

  private 
  # Never trust parameters from the scary internet, only allow the white list through.
  def componente_params
    params.require(:componentes).permit(:nome, :linha, :cd_empresa, :tipo)
  end


  #def reindex_componentes
  #  Componente.reindex
  #end


end
