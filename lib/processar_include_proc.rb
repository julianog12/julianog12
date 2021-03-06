# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true

class ProcessarIncludeProc
  attr_reader :cd_empresa, :servidor_funcao

  def initialize(empresa, servidor_funcao)
    @cd_empresa = empresa
    @servidor_funcao = servidor_funcao
    processar()
  end

  def deletar_include(nm_include)

    begin
      RestClient.delete "#{@servidor_funcao}/#{nm_include}", {params: 
        {
         cd_empresa: @cd_empresa,
         nm_funcao: nm_include,
  	     remover: '4'
        }
      }
    rescue
      nil
    end
  end

  def post_includes(nm_include, conteudo)
    v_conteudo = conteudo.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
    v_nr_linhas = v_conteudo.count("\n") unless v_conteudo.count("\n").nil?
    v_tipo = 'include'
    v_post_string = {'funcaos': {'cd_componente': nil,
              'tipo': v_tipo, 
              'nm_funcao': nm_include,
              'codigo': v_conteudo,
              'cd_empresa': @cd_empresa,
              'nm_campo': nil, 
              'nm_tabela': nil, 
              'nm_modelo': nil,
              'nr_linhas': v_nr_linhas || 1 }
            }
  
    begin
      funcao = Funcao.new
      funcao.cd_componente = nil
      funcao.tipo = v_tipo
      funcao.nm_funcao = nm_include
      funcao.codigo = v_conteudo
      funcao.cd_empresa = @cd_empresa
      funcao.nr_linhas = v_nr_linhas
      funcao.save
    	#v_post_string = v_post_string.to_json
      #RestClient.post "#{@servidor_funcao}", JSON.parse(v_post_string)
    rescue StandardError => e
      Rails.logger.info e.inspect
      Rails.logger.info "Erro Post Includes"
      Rails.logger.info v_post_string
    end
  end

  
  def processar
    v_arq_includes = Dir.glob("#{Rails.root}/lib/includes/#{@cd_empresa}_*.txt")
    
    v_arq_includes.each do |arquivo|
      v_nome = arquivo[(arquivo.rindex(/\//))+1..(arquivo.index(/\./)-1)].to_s.downcase
      v_nome = v_nome[2..(v_nome.index(/\Z/))]
      #deletar_include(v_nome)
      ProcessarEntryOperation.deletar_include4(@cd_empresa, v_nome)
      post_includes(v_nome, File.read(arquivo))
    end

  end
  
end