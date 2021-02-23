class Funcao < ApplicationRecord
  searchkick batch_size: 1000,
             settings: {number_of_shards: 1}, 
             word_middle: [:nm_funcao, :codigo, :documentacao, :tipo, :nm_campo, :nm_tabela]

  def search_data
    {
      nm_funcao:  nm_funcao,
      cd_componente: cd_componente,
      tipo: tipo,
      codigo: codigo,
      documentacao: documentacao,
      cd_empresa: cd_empresa,
      updated_at: updated_at,
      nm_campo: nm_campo,
      nm_tabela: nm_tabela
    }
  end


end
