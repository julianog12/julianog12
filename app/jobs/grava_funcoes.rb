class GravaFuncoes
  include Sidekiq::Worker

  def perform(dados)
    begin
      funcao = Funcao.new(dados)
      funcao.save
    rescue ActiveRecord::RecordNotUnique
      if dados["nm_campo"].empty?
        funcao = Funcao.where("nm_funcao = ? and cd_componente = ? and cd_empresa =  ?", 
                              dados["nm_funcao"], 
                              dados["cd_componente"].downcase, 
                              dados["cd_empresa"]).first
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
  end

end
