class Componente < ApplicationRecord
  searchkick settings: {number_of_shards: 1},
             word_middle: [:nome, :linha]

  def search_data
   {
       nome:  nome,
       linha: linha,
       cd_empresa: cd_empresa,
       updated_at: updated_at
   }
  end
  
end
