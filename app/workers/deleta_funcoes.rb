class DeletaFuncoes
  include Sidekiq::Worker

  def perform(reg)
    func = Funcao.new
    func.id = reg
    begin
      Funcao.searchkick_index.remove(func)
    rescue StandardError => e
      Rails.logger.info "##Erro ao deletar ID #{func.id}"
      Rails.logger.info e
    end
  end

end