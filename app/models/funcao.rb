class Funcao < ApplicationRecord
  searchkick batch_size: 500,
             settings: {number_of_shards: 1}, 
             word_middle: [:nm_funcao, :codigo, :documentacao]

  def search_data
   {
       nm_funcao:  nm_funcao,
       cd_componente: cd_componente,
       tipo: tipo,
       codigo: codigo,
       documentacao: documentacao,
       cd_empresa: cd_empresa,
       updated_at: updated_at
   }
   end


end
