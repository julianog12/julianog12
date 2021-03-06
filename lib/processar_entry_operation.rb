# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true

class ProcessarEntryOperation
  require "active_record"
  require "#{Rails.root}/lib/canivete.rb"
  attr_reader :cd_empresa, :nm_arquivo_importado, :servidor_funcao, :servidor_http, :diretorio_listener, :ultimo_diretorio, :arquivo

  def initialize(empresa, nm_arquivo_importado, servidor_funcao, servidor_http, diretorio_listener, ultimo_diretorio, arquivo)
    @cd_empresa = empresa
    @servidor_funcao = servidor_funcao
    @servidor_http = servidor_http
    @diretorio_listener = diretorio_listener
    @ultimo_diretorio = ultimo_diretorio
    @arquivo = arquivo
    @arq_importados = File.new(nm_arquivo_importado, 'w') unless nm_arquivo_importado.nil?
    processar()
  end

  def tipo_arquivo(v_arquivo)
    case v_arquivo
    when /.cptlst/i
      return 'Componente'
    when /.menlst/i
      return 'Menu'
    when /.apslst/i
      return 'StartUpShel'
    end
  end

  def linhaContemNewInstance(v_linha)
    v = (v_linha.match(/^newinstance\s.*\".*\"\,/i) || v_linha.match(/^new_instance\s.*\".*\"\,/i) || v_linha.match(/^newinstance\/.*\".*\"\,/i))
    if v
      begin
        v_linha = v_linha[(v_linha.index(/\s/)+1)..v_linha.index(/\z/)]
        dados = v_linha.split(",")

        v = dados[0].downcase != dados[1].downcase unless dados[0].nil? && dados[1].nil?
      rescue StandardError => e
        Rails.logger.info e
        Rails.logger.info '##Erro linhaContemNewInstance'
        Rails.logger.info v_linha
        Rails.logger.info dados.inspect
      end
    end
    v
  end

  def linhaContemActivate(v_linha)
    (!v_linha.match(/#include lib_coamo:g_vld_activate/) & (v_linha.match(/^activate\s.*\".*\"/i) || v_linha.match(/^activate\s.*/i) || v_linha.match(/^activate\/.*/i) || v_linha.match(/activate\/.*/i) || v_linha.match(/activate\s.*/i)))
  end

  def pegaNomeInstanca(v_linha)
    v_linha.scan(/\S+/)
  end

  def dados_funcao(v_linha)
    v_tipo_funcao = ''
    case 
     when v_linha.match(/^entry/i)
       v_tipo_funcao = 'entry'
    when v_linha.match(/^partner operation/i)
        v_tipo_funcao = 'partner-operation'
    when v_linha.match(/^public operation/i)
        v_tipo_funcao = 'operation'
    when v_linha.match(/^operation/i)
       v_tipo_funcao = 'operation'
    end
    if v_linha.split(' ').count <= 2
      begin
        v_nm_funcao = "#{v_linha[(v_linha.index(/\s/)+1)..v_linha.index(/\z/)]}".strip
      rescue StandardError => e
        v_nm_funcao = "#{v_linha[(v_linha.index(/\s/)+1)..v_linha.index(/\z/)]}"
      end
    elsif v_linha.include?('public') or v_linha.include?('partner')
      v_nm_funcao = "#{v_linha[(v_linha.index(/\s/)+1)..v_linha.index(/\z/)]}"
      v_nm_funcao = "#{v_nm_funcao[(v_nm_funcao.index(/\s/) + 1)..v_linha.index(/\z/)]}"
    else
      v_dados = v_linha.split(' ')
      v_nm_funcao = v_dados[1].strip
      if v_nm_funcao.match(/\;/)
        v_nm_funcao = v_nm_funcao[0..((v_nm_funcao.index(/\;/))-1)]
      end
    end
    v_nm_funcao = v_nm_funcao[0..(v_nm_funcao.index(/\s/))] unless v_nm_funcao.index(/\s/).nil?
    v_nm_funcao = v_nm_funcao.gsub('\n', '')
    v_nm_funcao = v_nm_funcao.gsub('\r', '')

    if v_tipo_funcao.empty? || v_nm_funcao.empty?
      Rails.logger.info "##Erro v_tipo_funcao ou v_nm_funcao est??o em branco!\n\n Linha #{v_linha}"
    end

    [v_tipo_funcao, v_nm_funcao]
  end

  def nome_include(linha, posic_include)
    nome = linha[(posic_include + 8)..(linha.index(/[\r\n]/)) - 1]
    unless nome.index(';').nil?
      nome = nome[0..(nome.index(';') - 1)]
    end
    nome.strip
  end

  def grava_arq_include(componente, nome_include, conteudo_include)
    arq_gravar = "#{Rails.root}/lib/includes/#{@cd_empresa}_#{nome_include.split(":")[1]}.txt"
    return if File.exists?(arq_gravar) || conteudo_include.empty?

    f = File.new(arq_gravar, 'w')
    f.write conteudo_include.join("\n")
    f.close
  end



  def post_lpmx(v_componente, v_tipo, v_nm_funcao = "LPMX", v_cmd)
    v_nr_linhas = v_cmd.size
    v_cmd = v_cmd.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")
    if !v_tipo.nil? && !v_tipo.empty?
      v_post_string = { 'funcaos': {
        'nm_funcao': v_nm_funcao,
        'cd_componente': v_componente.downcase,
        'tipo': v_tipo,
        'codigo': v_cmd,
        'documentacao': nil,
        'cd_empresa': @cd_empresa,
        'nr_linhas': v_nr_linhas || 1,
        'nm_modelo': nome_modelo(v_componente.downcase)
        }
      }
      v_delete_string = {
        params:
          {
            nm_funcao: v_nm_funcao,
            cd_empresa: @cd_empresa,
	          remover: '3'
          }
        }
      ProcessarEntryOperation.deletar_lpmx3(v_componente.downcase, @cd_empresa, v_nm_funcao)

      begin
        #RestClient.post "#{@servidor_funcao}", JSON.parse(v_post_string.to_json)
        funcao = Funcao.new
        funcao.nm_funcao = v_nm_funcao.downcase
        funcao.cd_componente = v_componente.downcase
        funcao.tipo = v_tipo
        funcao.codigo = v_cmd
        funcao.documentacao = nil
        funcao.cd_empresa = @cd_empresa
        funcao.nr_linhas = v_nr_linhas || 1
        funcao.nm_modelo = nome_modelo(v_componente.downcase)
        funcao.save
      rescue StandardError => e
        Rails.logger.info e.inspect
        Rails.logger.info '##Erro post_lpmx'
        Rails.logger.info '************************'
        Rails.logger.info v_post_string
        Rails.logger.info '********'
      end
    end
  end

  def post_entry_operation(v_componente, v_tipo, v_nm_funcao, v_cmd, v_cmd_real, v_cmd_docto)
    v_comando_real = v_cmd_real.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")
    v_comando_real = v_comando_real.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
    v_comando_docto = v_cmd_docto.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")
    v_comando_docto = v_comando_docto.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")

    if !v_tipo.nil? && !v_tipo.empty?
      v_post_string = { 'funcaos': {
        'nm_funcao': v_nm_funcao.downcase,
        'cd_componente': v_componente.downcase,
        'tipo': v_tipo,
        'codigo': v_comando_real,
        'documentacao': v_comando_docto,
        'cd_empresa': @cd_empresa,
        'nr_linhas': v_cmd.size || 1,
        'nm_modelo': nome_modelo(v_componente.downcase)
        }
      }
      begin
        #Rails.logger.error "#{v_componente.downcase}  -  #{v_tipo}  -  "
        #if v_componente.downcase == 'cesto137' && 
        #   v_tipo == 'operation' && 
        #   v_nm_funcao.downcase.include?('getrastroproducao')
        #  byebug
        #end
        
        #v_post_string = v_post_string.to_json
        #RestClient.post "#{@servidor_funcao}", JSON.parse(v_post_string)
        
        funcao = Funcao.new
        funcao.nm_funcao = v_nm_funcao.downcase
        funcao.cd_componente = v_componente.downcase
        funcao.tipo = v_tipo
        funcao.codigo = v_comando_real
        funcao.documentacao = v_comando_docto
        funcao.cd_empresa = @cd_empresa
        funcao.nr_linhas = v_cmd.size || 1
        funcao.nm_modelo = nome_modelo(v_componente.downcase)
        funcao.save
      
      rescue StandardError => e
        Rails.logger.info '************************'
        Rails.logger.info e.inspect
        Rails.logger.info '********'
        Rails.logger.info '##Erro post_entry_operation'
        Rails.logger.info v_post_string
      end      
    end
  end
 
  def linhaContem(v_linha)
    (!v_linha.match(/include lib_coamo:g_vld_activate/i) &
    (v_linha.match(/^activate\s.*\".*\"/i) ||
     v_linha.match(/^activate\s.*/i) ||
     v_linha.match(/^activate\/.*/i) ||
     v_linha.match(/activate\/.*/i) ||
     v_linha.match(/activate\s.*/i) ||
     v_linha.match(/^newinstance\s.*\".*\"\,/i) ||
     v_linha.match(/^new_instance\s.*\".*\"\,/i) ||
     v_linha.match(/^newinstance\/.*\".*\"\,/i) ||
     v_linha.match(/^new_instance\/.*\".*\"\,/i) ||
     v_linha.match(/^selectdb\s/i) ||
     v_linha.match(/^sql.*\,.*\"([a-z]{3})\"/i)))
  end

  def trata_linha_comentario(v_linha, endPosLine)
    v2 = v_linha.index(';')
    v_linha2 = v_linha[(v2+1)..endPosLine]
    v2 = v_linha2.index('|')
    if !v2.nil?
      v_linha2 = v_linha2[(v2+1)..endPosLine]
    end
    v2 = v_linha2.index(/\S/)
    if !v2.nil?
      v_linha2 = v_linha2[v2..endPosLine]
    end
    v2 = v_linha2.index('*****')
    if !v2.nil?
      v_linha2 = ''
    end
    v2 = v_linha2.index('=====')
    if !v2.nil?
      v_linha2 = ''
    end
    v2 = v_linha2.index('---')
    if !v2.nil?
      v_linha2 = ''
    end
    v_linha2[0..endPosLine]
  end

  def inicio_fim_linha(linha)
    v1 = linha.index("\n")
    if v1.nil?
      v_linha = linha[26..300]
    else
      v1 -= 1
      v_linha= linha[26..v1]
    end
    [v_linha, v1]
  end

  def comecou_trigger(v_linha)
    if v_linha.include?('Trigger <') && v_linha[26..26] != ";"
      nome = v_linha[(v_linha.index('<'))+1..(v_linha.index('>'))-1].strip
      tipo = v_linha[(v_linha.index('from')+5)..(v_linha.index(':')-1)]
      objeto = v_linha[(v_linha.index(':')+2)..(v_linha.index(/[\r\n]/))-1]
      return {nome: nome, tipo: tipo, objeto: objeto}
    end
  end

  def terminou_linha(v_linha)
    (!v_linha.match(/endw/i) &&
     !v_linha.match(/endf/i) &&
     !v_linha.match(/endi/i) &&
     !v_linha.match(/endv/i) &&
     !v_linha.match(/endp/i) &&
     !v_linha.nil? &&
     !v_linha.match(/^;/) &&
     !v_linha.match(/endselectcase/)) &
    (!!(v_linha.match(/^end\s/i)) || !!(v_linha.match(/^end\;/i)) || !!(v_linha.match(/^end/i)))
  end

  def nao_finalizou_leitura(linha)
    (linha[0..0] == '[' ||
     linha[0..0] == '('  ||
     linha.match(/   error:   /) ||
     linha[0..8] == "    info:" ||
     linha.match(/warning:   1000/) ||
     linha.match(/   warning: 1000/) ||
     linha.match(/ warning:   1000 - \(Prepro/) ||
     linha.match(/ warning:   1000 - Procs statements/))
  end


  def self.deletar_entry_operation1(v_id, v_cd_empresa)
    Funcao.where("cd_componente = ? and cd_empresa = ? and tipo in('entry', 'operation', 'partner-operation')", 
                  v_id.to_s,
                  v_cd_empresa.to_s).each do |reg|
      reg.delete
      begin
        ProcessarEntryOperation.deletar_funcao_elasticsearch(reg)
      rescue StandardError => e
        Rails.logger.error "##Erro ao deletar Funcao ElasticSearch linha 310"
        Rails.logger.error e
      end
    end
  end

  def self.deletar_triggers_fef2(v_id, v_cd_empresa)
    Funcao.where("cd_componente = ? and cd_empresa = ? and nm_funcao <> 'LPMX' and tipo in('trigger-form', 'trigger-field', 'trigger-entity')", 
                  v_id.to_s,
                  v_cd_empresa.to_s).each do |reg|
      reg.delete
      begin
        ProcessarEntryOperation.deletar_funcao_elasticsearch(reg)
      rescue StandardError => e
        Rails.logger.error "##Erro ao deletar params = 2 ElasticSearch"
        Rails.logger.error e
      end
    end
  end


  def self.deletar_lpmx3(v_id, v_cd_empresa, v_nm_funcao)
    Funcao.where("cd_componente = ? and cd_empresa = ? and nm_funcao = ? and tipo = 'trigger-form'", 
                    v_id.to_s,
                    v_cd_empresa.to_s,
                    v_nm_funcao.to_s).each do |reg|      
      reg.delete
      begin
        ProcessarEntryOperation.deletar_funcao_elasticsearch(reg)
      rescue StandardError => e
        Rails.logger.error "##Erro ao deletar params = 3 ElasticSearch"
        Rails.logger.error e
      end
    end
  end


  def self.deletar_include4(v_cd_empresa, v_nm_funcao)
    Funcao.where("cd_empresa = ? and nm_funcao = ? and tipo = 'include'",
                  v_cd_empresa.to_s,
                  v_nm_funcao.to_s).each do |reg|
      reg.delete
      begin
        ProcessarEntryOperation.deletar_funcao_elasticsearch(reg)
      rescue StandardError => e
        Rails.logger.error "##Erro ao deletar params = 4 ElasticSearch #{v_cd_empresa} #{v_nm_funcao}"
        Rails.logger.error e
      end
    end
  end

  
  def self.deletar_funcao_elasticsearch(reg)
    Funcao.searchkick_index.remove(reg)
  end


  def self.deletar_componente_elasticsearch(reg)
    Componente.searchkick_index.remove(reg)
  end

  def self.deletar_componente(v_id, v_cd_empresa)
    Componente.where("nome = ? and cd_empresa = ?", v_id.to_s, v_cd_empresa.to_s).each do |reg|
      reg.delete

      begin
        ProcessarEntryOperation.deletar_componente_elasticsearch(reg)
      rescue StandardError => e
        Rails.logger.error "##Erro ao deletar ElasticSearch Componente #{v_id} linha 333"
        Rails.logger.error e
      end

     end
  end

  def deletar_local_operations(v_id)
    ProcessarEntryOperation.deletar_componente(v_id, @cd_empresa)
    ProcessarEntryOperation.deletar_entry_operation1(v_id, @cd_empresa)

    #RestClient.delete "#{@servidor_http}/#{v_id}", {params:
    #  {
    #   nome: v_id,
    #   cd_empresa: @cd_empresa,
    #   remover: '1'
    #  }
    #}
    #RestClient.delete "#{@servidor_funcao}/#{v_id}", {params:
    #  {
    #   cd_componente: v_id,
    #   cd_empresa: @cd_empresa,
    #   remover: '1'
    #  }
    #}
  end

  def processar
    return nil if tipo_arquivo(@arquivo).nil?

    v_arquivo_ler = "#{@diretorio_listener}/#{@arquivo}"
    v_id = nome_arquivo(v_arquivo_ler)

    if (v_id.include?("_") | (v_id.length > 8)) && v_arquivo_ler.include?(".cptlst")
      return
    end

    begin
      ProcessarEntryOperation.deletar_componente(v_id, @cd_empresa)
      ProcessarEntryOperation.deletar_entry_operation1(v_id, @cd_empresa)
    rescue StandardError => e
      Rails.logger.info '##Erro deletar dados linha 371/372'
      Rails.logger.info e
      return nil
    end

    @arq_importados.write v_arquivo_ler unless nm_arquivo_importado.nil?
    @arq_importados.write "\n" unless nm_arquivo_importado.nil?

    v_cmd_activate = []
    v_indica = false
    v_indica_funcao = false
    v_cmd_funcao = []
    v_cmd_linha_funcao = []
    v_indica_docto = false
    v_cmd_docto = []
    v_indica_new_inst = false
    dados_new_instance= []
    nome_include = ''
    posic_include = 0
    conteudo_include = []
    dados_funcao = []
    dados_ini = []
    lpmx_includes = []
    iniciou_trigger = false
    terminou_trigger = false
    cont = 0

    File.read(v_arquivo_ler).each_line do |linha|
      cont += 1
      #Rails.logger.info "COMPONENTE #{v_id} - LINHA #{cont}    #{linha}"
      if lpmx_includes.any? && terminou_trigger
        post_lpmx(v_id, 'trigger-form', 'LPMX', lpmx_includes) if lpmx_includes.any?
        lpmx_includes = []
        iniciou_trigger = false
        terminou_trigger = false
      end

      if !iniciou_trigger || linha.include?('Trigger <')
        iniciou_trigger = false
        dados_ini = comecou_trigger(linha)
      end

      if !dados_ini.nil? && dados_ini[:nome] != 'DEFN' && !iniciou_trigger
        iniciou_trigger = true 
      else
        v_linha, posFinalLinha = inicio_fim_linha(linha)
        v_linha_funcao = v_linha
        v_linha = v_linha.lstrip unless v_linha.nil?
        if v_indica && !v_linha.nil?
          v_indica = v_linha.match(/\%\\/) ? true : false unless v_linha.nil?
          v_linha = tratar_linha(v_linha)
          if !v_linha.nil? && v_linha.size > 0
            v_cmd_activate << v_linha
          else
            v_indica = false
            v_cmd_activate = []
          end
        else
  
          posic_include = (linha.index("include LIB_COAMO:")||linha.index("include COAMO_LIB:")) ||0  if !v_linha.nil? && linha[0..1] == "[ " && !v_linha.match(/^;/) && !dados_ini.nil?
          if posic_include.positive?
            lpmx_includes << v_linha_funcao if dados_ini[:nome] == "LPMX"
            nova_include = nome_include(linha, posic_include)
            if nova_include != nome_include && nome_include.empty?
              nome_include = nova_include
            elsif nova_include != nome_include && !nome_include.empty?
              grava_arq_include(v_id, nome_include, conteudo_include)
              nome_include = nova_include
            end
            conteudo_include = []
            posic_include = 0
          end
          if !v_linha.nil? && !v_linha.blank? #Juliano 15/06/2021
            if linhaContemNewInstance(v_linha)
              v_indica_new_inst = true
              dados_new_instance = pegaNomeInstanca(v_linha)
            end
            if (!v_linha.match(/^;/) && v_linha.match(/^entry/i)) || (v_linha.match(/^operation/i) || v_linha.match(/^partner operation/i) || v_linha.match(/^public operation/i))
              dados_funcao = dados_funcao(v_linha)
              v_indica_funcao = true
              v_cmd_linha_funcao = []
		          v_cmd_funcao = []
            end
            v_indica_docto = true if v_linha.match(/\;\|/)
            if v_indica_docto
              if v_linha.match(/\;\|/) || v_linha.match(/\;/)
                v_linha = trata_linha_comentario(v_linha, posFinalLinha)
                v_cmd_docto << v_linha unless v_linha.nil?
              else
                v_indica_docto = false
              end
            end
            if linha[0..1] == "[I"
              conteudo_include << v_linha_funcao
            else
              if v_indica_funcao
                v_cmd_funcao << v_linha
                v_cmd_linha_funcao << v_linha_funcao
                if terminou_linha(v_linha)
                  #if v_id.downcase == 'pfato084' && dados_funcao[0].downcase == 'operation' && dados_funcao[1].include?('le_propriedade')
                  #  byebug
                  #end
                  post_entry_operation(v_id, dados_funcao[0], dados_funcao[1], v_cmd_funcao, v_cmd_linha_funcao, v_cmd_docto)
                  v_cmd_funcao = []
                  v_cmd_linha_funcao = []
                  v_indica_funcao = false
                  v_indica_docto = false
                  v_cmd_docto = []
                  dados_funcao = []
                end
              end
            end
            if v_cmd_activate.any?
              v_comando = v_cmd_activate.map(&:to_s).join('')
              v_comando = v_comando.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
              v_comando = v_comando.downcase.gsub('$componentname.', "\"#{v_id}\".")
              v_comando = v_comando.downcase.gsub('"$instancename.', "\"#{v_id}\".")
              v_comando = v_comando.downcase.gsub('%%$componentname', "#{v_id}")
              v_comando = v_comando.downcase.gsub('%%$instancename', "#{v_id}")
              v_post_string = {'componentes': {'nome': v_id, 'linha': v_comando, 'cd_empresa': @cd_empresa, 'tipo': tipo_arquivo(@arquivo) }}
              v_post_string = v_post_string.to_json
              begin
                RestClient.post "#{@servidor_http}", JSON.parse(v_post_string)
              rescue
                Rails.logger.info "##Erro ao chamar RestClient.post #{@servidor_http} linha 427 processar_entry_operation"
                nil
              end
              v_cmd_activate = []
              v_indica = false
            end
            if linhaContem(v_linha)
              if linhaContemActivate(v_linha)
                if !v_linha.match(/^activate.*/i) && !v_linha.match(/_activate.*/i)
                  v_linha = v_linha.downcase
                  v_linha = v_linha[v_linha.index('activate')..-1]  unless v_linha.index('activate')
                end
                if v_indica_new_inst
                  v_nome_instancia = dados_new_instance[2].gsub("\"", "").gsub(",","") unless dados_new_instance[2].nil?
                  v_variavel_instancia = dados_new_instance[1].gsub("\"", "").gsub(",","") unless dados_new_instance[1].nil?
                  unless v_nome_instancia.nil?
                    if v_nome_instancia != v_variavel_instancia and v_linha.include?(v_nome_instancia) and v_variavel_instancia != 'LOAD'
                      unless dados_new_instance[2].nil?
                        vTrocar = "\"#{dados_new_instance[2].gsub("\"", "").gsub(",","")}\"" unless dados_new_instance[2].nil?
                        v_linha = v_linha.gsub(vTrocar, "\"#{dados_new_instance[1].gsub("\"", '').gsub(",",'')}\"")
                        v_linha = v_linha.gsub("\"\"", "\"")
                      end
                    end
                  end
                end
              end
              v_indica = v_linha.match(/\%\\/) ? true : false
              unless v_indica
                if !v_linha[-1, 1].empty? && v_linha[-1, 1] != ')' && v_linha.length >= 248
                  v_indica = true
                end
              end
              v_linha = tratar_linha(v_linha)
              if !v_linha.nil? &&
                  v_linha.size.positive? &&
                  v_linha.start_with?(/^[a-z].*/i) &&
                  !v_linha.start_with?('else')
                v_cmd_activate << v_linha
              else
                v_indica = false
                v_cmd_activate = []
              end
            end
          end
          if nao_finalizou_leitura(linha) && iniciou_trigger
            #continuar leitura
          else
            if iniciou_trigger && lpmx_includes.any?
              terminou_trigger = true
            end
          end
        end
      end
    end
    if conteudo_include.any?
      grava_arq_include(v_id, nome_include, conteudo_include)
      conteudo_include = []
      nome_include = ''
    end
    @arq_importados.close unless nm_arquivo_importado.nil?
  end
end
