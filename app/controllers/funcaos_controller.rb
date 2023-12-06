class FuncaosController < ApplicationController
  helper_method :sort_column, :sort_direction 
  respond_to :json, :html, :js
  before_action :set_funcao, only: [:show, :edit, :update]

  def index
    @campos = []
    @keywords = ""
    @erro_ortografia = false
    @funcaos = []
    sort ||= "nm_funcao"
    if params[:sort].present?
       sort = params[:sort]
    end
    if params[:erro_ortografia].present?
      @erro_ortografia = params[:erro_ortografia]
    end

    if params[:cd_empresa].present?
       @cd_empresa = params[:cd_empresa]
    end
    if params[:fields].present?
       @campos = params[:fields].map{|n| n.to_sym}
    end

    if params[:keywords].present?
       @keywords = params[:keywords]
       if @campos.nil?
         @funcaos = Funcao.search(params[:keywords],
                                  where: {cd_empresa: @cd_empresa},
                                  operator: params[:operator_field],
                                  order: {sort_column => sort_direction},
                                  match: params[:match_field].to_sym,
                                  misspellings: eval(@erro_ortografia))
       else
         if params[:operator_field] == "like"
           if @campos.size > 1
             v_where = { cd_empresa: @cd_empresa}
           else
             v_where = { cd_empresa: @cd_empresa, "#{params[:fields].join("")}": {like: "%#{params[:keywords]}%"}}
           end
           @funcaos = Funcao.search(params[:keywords],
                                    fields: @campos,
                                    where: v_where, #{cd_empresa: @cd_empresa},
                                    order: {sort_column => sort_direction})
         else
           v_where = { cd_empresa: @cd_empresa}
           @funcaos = Funcao.search(params[:keywords],
                                    fields: @campos,
                                    where: v_where,
                                    operator: params[:operator_field],
                                    match: params[:match_field].to_sym,
                                    order: {sort_column => sort_direction},
                                    misspellings: eval(@erro_ortografia))
         end
       end
    end
    respond_with(@funcaos)
  end

  def show
    @mostrar = params[:mostrar]
    respond_with(@funcao)
  end

  def new
    @funcao = Funcao.new
    respond_with(@funcao)
  end

  def edit
  end

  def create
    dados = funcao_params
    #GravaFuncoes.perform_async(dados.to_h)

    begin
      funcao = Funcao.new(dados)
      if funcao.tipo == 'include'
        funcao_u = Funcao.where('cd_empresa = ? and nm_funcao = ? and tipo = ?', 
                                 funcao.cd_empresa.to_s, 
                                 funcao.nm_funcao, 
                                 funcao.tipo).first
        if funcao_u.nil?
          funcao.save
        end
      else
        funcao.save
      end
    rescue ActiveRecord::RecordNotUnique
      if dados["nm_campo"].empty?
        funcao = Funcao.where("nm_funcao = ? and cd_componente = ? and cd_empresa =  ?",
                              dados["nm_funcao"],
                              dados["cd_componente"].downcase,
                              dados["cd_empresa"].to_s).first
      else
        funcao = Funcao.where("nm_funcao = ? and cd_componente = ? and cd_empresa = ? and nm_campo = ? and nm_tabela = ?", 
                          dados["nm_funcao"],
                          dados["cd_componente"].downcase,
                          dados["cd_empresa"],
                          dados["nm_campo"],
                          dados["nm_tabela"]).first
      end
      begin
        funcao.update(dados)
      rescue StandardError => e
        raise e.inspect
      end
    rescue ActiveRecord::RecordInvalid => invalid
      raise e.inspect
    end
    render body: nil

    #@funcao = Funcao.new(dados)
    #begin
    #  @funcao.save
    #rescue ActiveRecord::RecordNotUnique
    #  set_funcao_custom(dados[:nm_funcao], dados[:cd_componente].downcase, dados[:cd_empresa],
    #                    dados[:nm_campo], dados[:nm_tabela])
    #  begin
    #    @funcao.update(dados)
    #  rescue StandardError => e
    #    raise e.inspect
    #  end
    #  render body: nil
    #rescue ActiveRecord::RecordInvalid => invalid
    #  raise e.inspect
    #  render body: nil
    #end
  end

  def update
    begin
      @funcao.update(funcao_params)
    rescue StandardError => e
      logger.info "AQUIERROUPDATE"
      logger.info e.inspect
    end
    respond_with(@funcao)
  end

  def destroy
    if params[:remover] == '1'
      ProcessarEntryOperation.deletar_entry_operation1(params[:cd_componente], params[:cd_empresa])
      #Funcao.where("cd_componente = ? and cd_empresa = ? and tipo in('entry', 'operation', 'partner-operation')", 
      #                  params[:cd_componente].to_s,
      #                  params[:cd_empresa].to_s).each do |reg|
      #  begin
      #    reg.delete
      #  rescue StandardError => e
      #    Rails.logger.info "##Erro ao deletar params = 1 componente #{params[:cd_componente]} empresa #{params[:cd_empresa]}"
      #    Rails.logger.info e
      #  end
      #  begin
      #    #DeletaFuncoes.perform_async(reg.id)
      #    Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.error "##Erro ao deletar params = 1 ElasticSearch"
      #    Rails.logger.error e
      #  end
      #end
    elsif params[:remover] == '2'

      ProcessarEntryOperation.deletar_triggers_fef2(params[:cd_componente], params[:cd_empresa])
      #Funcao.where("cd_componente = ? and cd_empresa = ? and nm_funcao <> 'LPMX' and tipo in('trigger-form', 'trigger-field', 'trigger-entity')", 
      #              params[:cd_componente].to_s,
      #              params[:cd_empresa].to_s).each do |reg|
      #  begin
      #    reg.delete
      #    #DeletaFuncoes.perform_async(reg.id)
      #    #Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.info "##Erro ao deletar params = 2 componente #{params[:cd_componente]} empresa #{params[:cd_empresa]}"
      #    Rails.logger.info e
      #  end
      #  begin
      #    #DeletaFuncoes.perform_async(reg.id)
      #    Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.error "##Erro ao deletar params = 2 ElasticSearch"
      #    Rails.logger.error e
      #  end
      #end
    elsif params[:remover] == '3'
      ProcessarEntryOperation.deletar_lpmx3(params[:id].to_s, params[:cd_empresa], params[:nm_funcao])
      #Funcao.where("cd_componente = ? and cd_empresa = ? and nm_funcao = ? and tipo = 'trigger-form'", 
      #              params[:id].to_s,
      #              params[:cd_empresa].to_s,
      #              params[:nm_funcao].to_s).each do |reg|
      #  begin      
      #    reg.delete
      #    #DeletaFuncoes.perform_async(reg.id)
      #    #Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.info "##Erro ao deletar params = 3 componente #{params[:id]} empresa #{params[:cd_empresa]}  Função #{params[:nm_funcao]}"
      #    Rails.logger.info e
      #  end
      #  begin
      #    #DeletaFuncoes.perform_async(reg.id)
      #    Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.error "##Erro ao deletar params = 3 ElasticSearch"
      #    Rails.logger.error e
      #  end
      #end

    elsif params[:remover] == '4'
      ProcessarEntryOperation.deletar_include4(params[:cd_empresa], params[:nm_funcao])
      #Funcao.where("cd_empresa = ? and nm_funcao = ? and tipo = 'include'", 
      #                    params[:cd_empresa].to_s,
      #                    params[:nm_funcao].to_s).each do |reg|
      #  begin
      #    reg.delete
      #    #DeletaFuncoes.perform_async(reg.id)
      #    #Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.info "##Erro ao deletar params = 4 empresa #{params[:cd_empresa]}  Função #{params[:nm_funcao]}"
      #    Rails.logger.info e
      #  end
      #  begin
      #    #DeletaFuncoes.perform_async(reg.id)
      #    Funcao.searchkick_index.remove(reg)
      #  rescue StandardError => e
      #    Rails.logger.error "##Erro ao deletar params = 4 ElasticSearch"
      #    Rails.logger.error e
      #  end
      #end
    end
    head :no_content
  end

  private

    def sort_column
      Funcao.column_names.include?(params[:sort]) ? params[:sort] : "nm_funcao"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def set_funcao_custom(nm_funcao, cd_componente, cd_empresa, nm_campo, nm_tabela)
      if nm_campo.empty?
         @funcao = Funcao.where("nm_funcao = ? and cd_componente = ? and cd_empresa =  ?", nm_funcao, cd_componente, cd_empresa).first
      else
        @funcao = Funcao.where("nm_funcao = ? and cd_componente = ? and cd_empresa =  ?
                          and nm_campo = ? and nm_tabela = ?", nm_funcao, cd_componente, cd_empresa, nm_campo, nm_tabela).first
      end
    end

    def set_funcao
      @funcao = Funcao.find(params[:id])
    end

    def funcao_params
      params.require(:funcaos).permit(:nm_funcao, 
                                      :cd_componente, 
                                      :tipo, 
                                      :codigo, 
                                      :documentacao, 
                                      :cd_empresa, 
                                      :remover, 
                                      :nm_tabela,
                                      :nm_campo,
                                      :nm_modelo,
                                      :id,
                                      :nr_linhas)
    end
end
