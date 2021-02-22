# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true


class ProcessarTrigger
  attr_reader :cd_empresa, :servidor_funcao, :servidor_http, :diretorio_listener, :ultimo_diretorio, :arquivo

  def initialize(empresa, servidor_funcao, servidor_http, diretorio_listener, ultimo_diretorio, arquivo)
    @cd_empresa = empresa
    @servidor_funcao = servidor_funcao
    @servidor_http = servidor_http
    @diretorio_listener = diretorio_listener
    @ultimo_diretorio = ultimo_diretorio
    @arquivo = arquivo
    processar()
  end

  def inicio_trigger(linha)
    if linha.include?('Trigger <')
      nome = linha[(linha.index('<'))+1..(linha.index('>'))-1].strip
      tipo = linha[(linha.index('from')+5)..(linha.index(':')-1)]
      objeto = linha[(linha.index(':')+2)..(linha.index(/[\r\n]/))-1]
      return {nome: nome, tipo: tipo, objeto: objeto}
    end
  end

  
  def discartar_trigger(conteudo)
    (conteudo.match(/#include LIB_COAMO:G_ONERROR/) ||
   conteudo.match(/#include LIB_COAMO:G_READ/) ||
   conteudo.match(/#include LIB_COAMO:G_DELETE/) ||
   conteudo.match(/#include LIB_COAMO:G_LMKEY/) ||
   conteudo.match(/#include LIB_COAMO:G_LOCK/) ||
   conteudo.match(/#include LIB_COAMO:G_ERASE/) ||
   conteudo.match(/#include LIB_COAMO:G_REMOVEOCC/) ||
   conteudo.match(/#include LIB_COAMO:GSEG_VALIDASENHA/) ||
   conteudo.match(/#include LIB_COAMO:GSEG_VALSENHA_SO/) ||
   conteudo.match(/#include LIB_COAMO:G_VLDKEY/) ||
   conteudo.match(/#include LIB_COAMO:G_MAIORZERO/) ||
   conteudo.match(/#include LIB_COAMO:G_VALC_DIG/) ||
   conteudo.match(/#include LIB_COAMO:G_RETRSEQ/) ||
   conteudo.match(/#include LIB_COAMO:G_FORMAT_DIG/) ||
   conteudo.match(/#include LIB_COAMO:G_ONERROR/) ||
   conteudo.match(/#include LIB_COAMO:G_WRITE/) ||
   conteudo.match(/#include LIB_COAMO:G_STORE/) ||
   conteudo.match(/#include LIB_COAMO:G_CLEAR/) ||
   conteudo.match(/#include LIB_COAMO:G_QUIT/) ||
   conteudo.match(/#include LIB_COAMO:G_RETRSEQ/) ||
   conteudo.match(/#include LIB_COAMO:G_HIST_ALT/))
  end


  def discartar_trigger2(conteudo)
    (conteudo.match(/^return\(-1\)/i) ||
     conteudo.match(/^return \(-1\)/i) ||
     conteudo.match(/^return \(-99\)/i) ||
     conteudo.match(/^return\(-99\)/i) ||
  	 conteudo.match(/^return -1/i) ||
     conteudo.match(/^exit\(0\)/i) ||
     conteudo.match(/^exit/i))
  end

  def discartar_trigger3(conteudo)
    conteudo = conteudo.to_s.gsub("\r", '').gsub("\n", '').gsub(' ', '')
    (conteudo.include?('params$T_CD_OPERADOR$:IN;;incluirapartirdestepontoosparâmetrosreferentesaoseuprograma,estedeverasersempreoprimeiroparametroendparams'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?"))) ||
    (conteudo.include?('params$T_CD_OPERADOR$:IN;;incluirapartirdestepontoosparâmetrosreferentesaoseuprograma,estedeverasersempreoprimeiroparametroendparamsedit'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")))
  end


  def post_triggers(componente, nome_trigger, objeto, tipo_trigger, conteudo_trigger)
    begin
      conteudo_trigger = conteudo_trigger.reject { |c| c.empty? unless c.nil? } unless !nome_trigger == 'ERRF'
    rescue StandardError => e
      puts e
      puts componente 
      puts nome_trigger
      puts objeto
      puts tipo_trigger
      puts conteudo_trigger
      raise "Stop"
    end
    dados_objeto = objeto.split('.')

    v_dados_funcao = conteudo_trigger.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")
    v_dados_funcao = v_dados_funcao.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")
    return if (conteudo_trigger.size == 1 && (discartar_trigger(conteudo_trigger[0]) || discartar_trigger2(conteudo_trigger[0]))) || 
               (conteudo_trigger.size == 2 && conteudo_trigger[1] == "\r" && discartar_trigger(conteudo_trigger[0])) ||
               discartar_trigger2(conteudo_trigger[0]) ||
               discartar_trigger3(v_dados_funcao) ||
               nome_trigger == 'OPER' ||
               nome_trigger == 'LPMX'

    if dados_objeto.size == 3
      nm_campo = dados_objeto[0].downcase
      nm_tabela = dados_objeto[1].downcase
      nm_modelo = dados_objeto[2].downcase
    elsif dados_objeto.size == 2
      nm_tabela = dados_objeto[0].downcase
      nm_modelo = dados_objeto[1].downcase
    end

    v_tipo = ''
    if tipo_trigger.match(/Form/i)
      v_tipo = 'trigger-form'
    elsif tipo_trigger.match(/Field/i)
      v_tipo = 'trigger-field'
    elsif tipo_trigger.match(/Entity/i)
      v_tipo = 'trigger-entity'
    else
      v_tipo = 'trigger-form'
    end
    
    v_post_string = {'funcaos': {'cd_componente': componente, 
              'tipo': v_tipo, 
              'nm_funcao': nome_trigger,
              'codigo': v_dados_funcao,
              'cd_empresa': @cd_empresa,
              'nm_campo': nm_campo, 
              'nm_tabela': nm_tabela, 
              'nm_modelo': nm_modelo }
            }
  
    begin
      RestClient.post "#{@servidor_funcao}", JSON.parse(v_post_string.to_json)
    rescue StandardError => e
      Rails.info e.inspect
      Rails.info "Erro ao fazer post funcao"
      Rails.info v_post_string
    end
    
  end
  
  
  def grava_arq_include(componente, nome_include, conteudo_include)
    return if File.exists?("#{Rails.root}/lib/includes/#{componente}_#{nome_include.split(":")[1]}.txt") || conteudo_include.empty?
  
    f = File.new("#{Rails.root}/lib/includes/#{nome_include.split(':')[1]}.txt", 'w')
    f.write conteudo_include.join("\n")
    f.close
  end
  
  
  def nome_include(linha, posic_include)
    nome = linha[(posic_include + 8)..(linha.index(/[\r\n]/)) - 1]
    unless nome.index(';').nil?
      nome = nome[0..(nome.index(';') - 1)]
    end
    nome.strip
  end
  
  def nome_arquivo(arquivo)
    if arquivo.include?("/")
      parte_arq = arquivo.rindex(/\//) + 1
      arquivo[(parte_arq)..(arquivo.index('.') - 1)]
    else
      arquivo[0..(arquivo.index('.') - 1)] 
    end
  end

  def deletar_triggers(componente)
    RestClient.delete "#{@servidor_funcao}/#{componente}", {params: 
      {
       cd_componente: componente,
       cd_empresa: @cd_empresa,
  	   remover: '2'
      }
    }
  end


  
  def processar
    v_arquivo_ler = "#{@diretorio_listener}/#{@arquivo}"
    nm_arquivo = nome_arquivo(v_arquivo_ler)
  
    begin
      deletar_triggers(nm_arquivo)
    rescue StandardError => e
       Rails.logger.info 'Erro deletar funcao deletar_dados para o componeten #{nm_arquivo}'
       Rails.logger.info e
      end
  
    iniciou_trigger = false
    terminou_trigger = false
    nome_include = ''
    posic_include = 0
    nome_trigger = ''
    tipo_trigger = ''
    objeto = ''
    conteudo_trigger = []
    conteudo_include = []
    total = 0


    File.read(v_arquivo_ler).each_line do |linha|
      linhar = linha[26...(linha.index(/\Z/))]
      total += 1
      if conteudo_trigger.any? && terminou_trigger
        post_triggers(nm_arquivo,
                      nome_trigger, 
                      objeto, 
                      tipo_trigger, 
                      conteudo_trigger)
        nome_trigger = ''
        conteudo_trigger = []
        objeto = ''
        tipo_trigger = ''
        iniciou_trigger = false
        terminou_trigger = false
      end
      if !linhar.nil?
        dados_ini = inicio_trigger(linha) unless iniciou_trigger
        if !dados_ini.nil? && dados_ini[:nome] != 'DEFN' && !iniciou_trigger
          iniciou_trigger = true
          nome_trigger = dados_ini[:nome]
          tipo_trigger = dados_ini[:tipo]
          objeto = dados_ini[:objeto]
          next
        end
      end
      posic_include = (linha.index("include LIB_COAMO:") || linha.index("include COAMO_LIB:")) || 0  if !linhar.nil? && linha[0..1] == "[ " && !linhar.match(/^;/)

      if posic_include.positive?
        nova_include = nome_include(linha, posic_include)
        if nova_include != nome_include && nome_include.empty?
          nome_include = nova_include
        elsif nova_include != nome_include && !nome_include.empty?
          grava_arq_include(nm_arquivo, nome_include, conteudo_include)
          nome_include = nova_include
        end
        conteudo_include = []
        posic_include = 0
      end

      if linha[0..0] == "[" and iniciou_trigger
        if linha[0..1] == "[I"
          conteudo_include << linha[26...(linha.index(/\Z/))]
        else
          conteudo_trigger << linha[26...(linha.index(/\Z/))]
        end
      else
        if iniciou_trigger && conteudo_trigger.any?
          terminou_trigger = true
        end
      end
    end
    if conteudo_trigger.any?
      post_triggers(nm_arquivo,
                    nome_trigger, 
                    objeto, 
                    tipo_trigger, 
                    conteudo_trigger)
      nome_trigger = ''
      conteudo_trigger = []
      objeto = ''
      tipo_trigger = ''
      iniciou_trigger = false
      terminou_trigger = true
    end
    if conteudo_include.any?
      grava_arq_include(nm_arquivo, nome_include, conteudo_include)
      conteudo_include = []
      nome_include = ''
    end
  end
  
end