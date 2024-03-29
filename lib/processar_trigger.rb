# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true


class ProcessarTrigger
  #require 'active_record'
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

  def trigger_externa(linha, objeto, nome, tipo)
    if linha.include?('Trigger <') && linha[0.0] != '['
      objeto = linha[(linha.index(':')+2)..(linha.index(/[\r\n]/))-1]
      nome = linha[(linha.index('<'))+1..(linha.index('>'))-1].strip
      tipo = linha[(linha.index('from')+5)..(linha.index(':')-1)]
      return {nome_externo: nome, tipo: tipo, objeto: objeto}
    end
  end


  def inicio_trigger(linha)
    if linha.include?('******        trigger ')
      nome = linha[22..(linha.index(/\Z/))].strip
      return {nome: nome}
    end
  end


  def fim_trigger(linha)
    return (linha.include?('#include LIB_COAMO:G_VALIDA_CONST') ||
            linha.include?('#include LIB_COAMO:G_TRATA_ERRO') ||
            linha.include?('#include LIB_COAMO:G_HIST_ALT') ||
            linha.include?('******        operation ') ||
        linha.include?("\bend\n") ||
        linha.include?('Trigger <') ||
        linha.match(/.*(\bend\n|\bend.*\;)/i) ||
        linha.include?('******        trigger ') ||
        linha.match(/\;*.autor*.\:/i))
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


  def discartar_trigger(conteudo)
    (conteudo.match(/#include LIB_COAMO:G_ONERROR/i) ||
   conteudo.match(/#include LIB_COAMO:G_READ/i) ||
   conteudo.match(/#include LIB_COAMO:G_DELETE/i) ||
   conteudo.match(/#include LIB_COAMO:G_LMKEY/i) ||
   conteudo.match(/#include LIB_COAMO:G_LOCK/) ||
   conteudo.match(/#include LIB_COAMO:G_ERASE/) ||
   conteudo.match(/#include LIB_COAMO:G_REMOVEOCC/) ||
   conteudo.match(/#include LIB_COAMO:GSEG_VALIDASENHA/i) ||
   conteudo.match(/#include LIB_COAMO:GSEG_VALSENHA_SO/i) ||
   conteudo.match(/#include LIB_COAMO:G_VLDKEY/i) ||
   conteudo.match(/#include LIB_COAMO:G_MAIORZERO/) ||
   conteudo.match(/#include LIB_COAMO:G_VALC_DIG/) ||
   conteudo.match(/#include LIB_COAMO:G_RETRSEQ/) ||
   conteudo.match(/#include LIB_COAMO:G_FORMAT_DIG/) ||
   conteudo.match(/#include LIB_COAMO:G_ONERROR/) ||
   conteudo.match(/#include COAMO_LIB:G_ONERROR/) ||
   conteudo.match(/#include LIB_COAMO:G_WRITE/) ||
   conteudo.match(/#include LIB_COAMO:G_STORE/) ||
   conteudo.match(/#include LIB_COAMO:G_CLEAR/) ||
   conteudo.match(/#include LIB_COAMO:G_QUIT/) ||
   conteudo.match(/#include LIB_COAMO:G_RETRSEQ/) ||
   conteudo.match(/#include LIB_COAMO:G_RETRIEVE/) ||
   conteudo.match(/#include LIB_COAMO:G_HIST_ALT/) ||
   conteudo.match(/#include COAMO_LIB:C_ERRENT_LOCK/i) ||
   conteudo.match(/#include COAMO_LIB:C_LOCK_RB/i))
  end

  def discartar_trigger2(conteudo)
    (conteudo.match(/^return\(-1\)/i) ||
     conteudo.match(/^clear/i) ||
     conteudo.match(/^return \(-1\)/i) ||
     conteudo.match(/^return \(-99\)/i) ||
     conteudo.match(/^return\(-99\)/i) ||
     conteudo.match(/.*return\(-99\).*/i) ||
  	 conteudo.match(/^return -1/i) ||
     conteudo.match(/^exit\(0\)/i) ||
     conteudo.match(/^exit/i) ||
     conteudo.match(/^return \(0\)/i) ||
     conteudo.match(/^return\(0\)/i) ||
     conteudo.match(/^macro "\^QUIT"/i) ||
     conteudo.match(/^macro "\^STORE"/i))
  end

  def discartar_trigger3(conteudo)
    conteudo = conteudo.to_s.gsub("\r\n", '').gsub("\n", '').gsub(' ', '').gsub("\r", '')
    conteudo.include?('throws;Thistriggerisfiredoneverykeypressdonebytheuser;Yourimplementationhere...') ||
    conteudo.match(/cd_operador.*.*\=\$t_cd_operador\$dt_transacao.*\=\$datim/i) ||
    conteudo.include?('paramsstringfieldName:innumericshiftKey:inendparams') ||
    conteudo.include?('paramsnumericshiftKey:inendparams') ||
    conteudo.include?('paramsstringcolumnName:innumericviewportWidthPx:instringcolumnWidthsPx:inendparams') ||
    conteudo.include?('params$T_CD_OPERADOR$:IN;;incluirapartirdestepontoosparâmetrosreferentesaoseuprograma,estedeverasersempreoprimeiroparametroendparams') ||
    conteudo.include?(';Includean"else"blockliketheoneshownbelowattheendofany;Procwritteninthistrigger.;...;else;message$text("%%$error");return(-1);endif') ||
    conteudo.include?('params$T_CD_OPERADOR$:IN;;incluirapartirdestepontoosparâmetrosreferentesaoseuprograma,estedeverasersempreoprimeiroparametroendparamsedit'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('variablesnumericv_nr_tam,v_nr_posstringv_nr_cpfcnpj,v_cd_digitoendvariablesif($fieldmod=1)length@$fieldnamev_nr_tam=$resultv_nr_pos=1v_nr_cpfcnpj=""repeatif(@$fieldname[v_nr_pos:1]=\'#\')v_nr_cpfcnpj="%%v_nr_cpfcnpj%%@$fieldname[v_nr_pos:1]"endifv_nr_pos=v_nr_pos+1until(v_nr_pos>v_nr_tam)@$fieldname=v_nr_cpfcnpjlength@$fieldnameif($result>11)activate"GSISO002".DIG_CNPJ(@$fieldname,v_cd_digito,$t_ds_erro$)else;activate"GSISO002".DIG_CPF(@$fieldname,v_cd_digito,$t_ds_erro$)endifif($status<0)if($status=-99);Trataoretornocomerromessage/error"%%$t_ds_erro$"return(-1)else;VerificaoerrodoactivatecallPL_ERRO_COMANDO($procerrorcontext)return(-1)endifendifendif'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('lockif($status=-10)reload'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('findkey$entname,$curkeySelectCase$statusCase0;keynotfoundif($foreign);nonexistingkeyinupentityreturn(-1);onlyifWriteUptriggernotfilledendif;Case1;keyfoundonComponent;if(!$foreign);duplicatekeyindownentity;return(-1);endif;Case2;keyfoundinDBMS;if(!$foreign);duplicatekeyindownentity;return(-1);endifEndSelectCasereturn(0)'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('if($format!="")length$formatif($result=11)$format="%%$format[1:3].%%$format[4:3].%%$format[7:3]-%%$format[10:2]"elseif($result=14)$format="%%$format[1:2].%%$format[3:3].%%$format[6:3]%\/%%$format[9:4]-%%$format[13:2]"endifendifendif'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('findkey$entname,$curkeySelectCase$statusCase0;keynotfoundif($foreign);nonexistingkeyinupentityreturn(-1);onlyifWriteUptriggernotfilledendifCase1;keyfoundonComponentif(!$foreign);duplicatekeyindownentityreturn(-1)endifCase2;keyfoundinDBMSif(!$foreign);duplicatekeyindownentityreturn(-1)endifEndSelectCasereturn(0)'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('retrieve/oif($status<0)if($status=-15)message$text(2202);Multiplehits:inforeignentityif($status=-14)message$text(2205);Multiplehits:notinforeignentityif($status=-11)message$text(2009);Occurrencecurrentlylockedif($status=-7)message$text(2006);Duplicatekeyif($status=-4)message$text(2003);Cannotopentableorfileif($status=-3)message$text(2002);ExceptionalI/Oerrorif($status=-2)message$text(2200);Keynotfound:inforeignentityelseif($status=1)message$text(2201);Keynotfound:foreignentityw/WRITEUPif($status=2);Oneoccurrencefoundinforeignentityretrieve/eif($status<0)message$text(2002);I/Oerrordetectedendifif($status=3)message$text(2203);Occurrenceun-removedif($status=4)message$text(2204);Keyfound:occurrencerepositionedendifreturn($status)'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")) ||
    conteudo.include?('retrieveif($status<0)message"Retrievesequentialdidnotsucceed;seemessageframe"endif)end'.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?"))
  end
  

  def discartar_trigger4(conteudo)
    (conteudo.match(/^call PG_REMOVE/i) ||
     conteudo.match(/^delete/i) ||
     conteudo.match(/^read/i) ||
     conteudo.match(/^write/i) ||
     conteudo.match(/^call PG_LMKEY/i) ||
     conteudo.match(/^call pg_operador/i) ||
     conteudo.match(/^call PG_ERRENTITY/i) ||
     conteudo.match(/^write/) ||
     conteudo.match(/^call PG_ERRFIELD/i) ||
     conteudo.match(/^call pg_store/i) ||
     conteudo.match(/^call pg_retrieve/i) ||
     conteudo.match(/^call pg_quit/i) ||
     conteudo.match(/^call pg_clear/i) ||
     conteudo.match(/^call PG_MAIORZERO/i))
  end


  def post_triggers(componente, nome_externo, nome_trigger, objeto, tipo_trigger, conteudo_trigger)
    begin
      conteudo_trigger = conteudo_trigger.reject { |c| c.empty? unless c.nil? } unless !nome_trigger == 'ERRF'
    rescue StandardError => e
      Rails.logger.info e
      Rails.logger.info "##Erro ao montar conteudo da trigger (post_triggers - L103). Componente #{componente}, Trigger #{nome_trigger}"
      return
    end

    dados_objeto = objeto.split('.')
    v_dados_funcao = conteudo_trigger.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")
    v_dados_funcao = v_dados_funcao.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => "?")

    return  if conteudo_trigger.empty? ||
              (conteudo_trigger.size == 1 && (discartar_trigger(conteudo_trigger[0]) || discartar_trigger2(conteudo_trigger[0]))) || 
              (conteudo_trigger.size == 2 && conteudo_trigger[1] == "\r" && discartar_trigger(conteudo_trigger[0])) ||
               discartar_trigger2(conteudo_trigger[0]) ||
               discartar_trigger3(v_dados_funcao) ||
               discartar_trigger4(v_dados_funcao) ||
               nome_trigger == 'OPER' ||
               nome_trigger == 'LPMX' ||
               conteudo_trigger.join('').length <= 5

    nm_modelo = nome_modelo(componente.downcase)
    if dados_objeto.size == 3
      nm_campo = dados_objeto[0].downcase
      nm_tabela = dados_objeto[1].downcase
      nm_modelo = dados_objeto[3].downcase unless dados_objeto[3].nil?
    elsif dados_objeto.size == 2
      nm_tabela = dados_objeto[0].downcase
      nm_modelo = dados_objeto[1].downcase
    end

    v_tipo = ''
    if tipo_trigger.match(/Form/i)
      v_tipo = 'trigger-form'
      nm_modelo = nil
    elsif tipo_trigger.match(/Field/i)
      v_tipo = 'trigger-field'
    elsif tipo_trigger.match(/Entity/i)
      v_tipo = 'trigger-entity'
    else
      v_tipo = 'trigger-form'
      nm_modelo = nil
    end

    if nome_trigger.blank?
      nome_trigger = nome_externo
    end

    v_post_string = {'funcaos': {'cd_componente': componente, 
              'tipo': v_tipo, 
              'nm_funcao': nome_trigger,
              'codigo': v_dados_funcao,
              'cd_empresa': @cd_empresa,
              'nm_campo': nm_campo, 
              'nm_tabela': nm_tabela, 
              'nm_modelo': nm_modelo,
              'nr_linhas': conteudo_trigger.size }
            }
    funcao = Funcao.new
    begin
      funcao.nm_funcao = nome_trigger.downcase
      funcao.cd_componente = componente.downcase
      funcao.tipo = v_tipo
      funcao.codigo = v_dados_funcao
      funcao.documentacao = nil
      funcao.nm_campo = nm_campo
      funcao.nm_tabela = nm_tabela
      funcao.cd_empresa = @cd_empresa
      funcao.nr_linhas = conteudo_trigger.size || 1
      funcao.nm_modelo = nm_modelo #nome_modelo(componente.downcase)
      funcao.save
      funcao = nil
      #RestClient.post "#{@servidor_funcao}", JSON.parse(v_post_string.to_json)
    rescue StandardError => e
      Rails.logger.info '##Erro ao fazer post funcao em processar_trigger linha 160'
      Rails.logger.info v_post_string
      Rails.logger.info e
    end
  end

  def grava_arq_include(componente, nome_include, conteudo_include)
    arq_include = "#{Rails.root}/lib/includes/#{@cd_empresa}_#{nome_include.split(":")[1]}.txt"
    return if File.exists?(arq_include) || conteudo_include.empty?

    f = File.new(arq_include, 'w')
    f.write conteudo_include.join("\n")
    f.close
  end


  
  def processar
    v_arquivo_ler = "#{@diretorio_listener}/#{@arquivo}"
    nm_arquivo = nome_arquivo(v_arquivo_ler)

    if nm_arquivo.include?("_") && nm_arquivo.length > 8 && !nm_arquivo.include?("@")
      return
    end
  
    begin
      Rails.logger.info "##debugg Vai entrar ProcessarEntryOperation.deletar_triggers_fef2 #{nm_arquivo} da empresa #{@cd_empresa}"
      ProcessarEntryOperation.deletar_triggers_fef2(nm_arquivo.downcase, @cd_empresa)
    rescue StandardError => e
      Rails.logger.info "##Erro deletar funcao deletar_dados para o componente #{nm_arquivo}"
      Rails.logger.info e
      return nil
    end
    iniciou_trigger = false
    terminou_trigger = false
    nome_trigger = ''
    tipo_trigger = ''
    objeto = ''
    nome_externo = ''
    conteudo_trigger = []
    total = 0

    File.read(v_arquivo_ler).each_line do |linha|
      linhar = linha[26...(linha.index(/\Z/))]
      total += 1
      if conteudo_trigger.any? && fim_trigger(linha)
        post_triggers(nm_arquivo,
                      nome_externo,
                      nome_trigger,
                      objeto,
                      tipo_trigger,
                      conteudo_trigger)
        nome_trigger = ''
        conteudo_trigger = []
        iniciou_trigger = false
        terminou_trigger = false
      end
      unless linhar.nil?
        trigger_externa = trigger_externa(linha, objeto, nome_externo, tipo_trigger) unless iniciou_trigger
        if !trigger_externa.nil? && trigger_externa[:nome_externo] != 'DEFN' && !iniciou_trigger
          tipo_trigger = trigger_externa[:tipo]
          nome_externo = trigger_externa[:nome_externo]
          objeto = trigger_externa[:objeto]
          if trigger_externa[:nome_externo] == 'DCLC'
            iniciou_trigger = true 
            dados_ini = {nome: 'DCLC'}
          end
          next
        end
        dados_ini = inicio_trigger(linha) unless iniciou_trigger
        if !dados_ini.nil? && dados_ini[:nome] != 'DEFN' && !iniciou_trigger
          iniciou_trigger = true
          terminou_trigger = false
          nome_trigger = dados_ini[:nome]
          next
        end
      end
      if linha[0..0] == '[' and iniciou_trigger
        if linha[0..1] != '[I'
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
                    nome_externo,
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
  end

end