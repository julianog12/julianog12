class GerarArquivo
  require 'open3'
  require "#{Rails.root}/lib/canivete.rb"

  def initialize(caminho_config)
    @caminho = caminho_config
    @arq_yml = YAML::load(File.open(@caminho))
    @cd_empresa = @arq_yml['ambiente']['empresa']

    @nm_arquivo = "#{Rails.root}/lib/arquivos_gerados/" + @arq_yml['geral']['nome_arq_result'] + "_#{Time.now.strftime('%d%m%Y%H%M%S')}"
    @nm_arquivos_importados = "#{Rails.root}/lib/arquivos_gerados/" + "#{@cd_empresa}_importados"  + "_#{Time.now.strftime('%d_%m_%Y_%H_%M_%S')}" 

    begin
      File.delete("#{Rails.root}/lib/arquivos_gerados/" + "#{@cd_empresa}_importados_*")
    rescue
      nil
    end

    @extensao_arquivo = (@arq_yml['ambiente']['extensao_leitura'] == 'all' ? "*" : @arq_yml['ambiente']['extensao_leitura'])
    @servidor_funcao = @arq_yml['geral']['servidor_http_funcao']
    @servidor_http = @arq_yml['geral']['servidor_http']
    @diretorio_listener = @arq_yml['ambiente']['diretorio_listener']
    @ultimo_diretorio = @arq_yml['geral']['ultimo_diretorio'] 
    @data_ultima_alteracao= ler_arquivo_ultima_alteracao(@arq_yml['geral']['ultima_alteracao'].split(" "))

    gerar_arquivo
    processar

    begin
      File.delete(@nm_arquivo)
    rescue Exception => e
      nil
    end
    gravar_arquivo_ultima_alteracao
  end

  def ler_arquivo_ultima_alteracao(data)
    Time.new(data[0], data[1], data[2], data[3], data[4], data[5])
  end

  def gravar_arquivo_ultima_alteracao
    data = Time.now.strftime("%Y %m %d %H %M %S").to_s
    @arq_yml['geral']['ultima_alteracao'] = data
    File.open(@caminho, "w") {|f| f.write @arq_yml.to_yaml}
  end

  def linhaContemNewInstance(vLinha)
    v= (vLinha.match(/^newinstance\s.*\".*\"\,/i) or vLinha.match(/^new_instance\s.*\".*\"\,/i) or vLinha.match(/^newinstance\/.*\".*\"\,/i))
    if v
      begin
        dados = vLinha.scan(/\S+/)
        v = dados[1].downcase != dados[2].downcase unless dados[1].nil? and dados[2].nil?
      rescue
        Rails.logger.info "AAAEEEE"
        Rails.logger.info dados.inspect
      end
    end
    v
  end

  def linhaContemActivate(vLinha)
    (vLinha.match(/^activate\s.*\".*\"/i) or vLinha.match(/^activate\s.*/i) or vLinha.match(/^activate\/.*/i) or vLinha.match(/activate\/.*/i) or vLinha.match(/activate\s.*/i))
  end

  def pegaNomeInstanca(vLinha)
    vLinha.scan(/\S+/)
  end

  def gerar_arquivo
    f = nil
    if @extensao_arquivo == "*"
      f = open("| ls -lt --time-style='+%d%m%Y %H%M' #{@diretorio_listener}/")
    else
      f = open("| ls -lt --time-style='+%d%m%Y %H%M' #{@diretorio_listener}/*.#{@extensao_arquivo}")
    end
    a = File.new(@nm_arquivo, "w")
    a.write f.read.force_encoding('UTF-8')
    a.close
    @arq_importados = File.new(@nm_arquivos_importados, "w")
  end

  def post_funcao(vComponente, vCmd, vCmdReal, vCmdDocto)
    vComando = vCmd.map { |i| i.to_s.gsub("\t", "  ") }.join("\n")
    vComandoReal = vCmdReal.map { |i| i.to_s.gsub("\t", "  ") }.join("\n")
    vComandoDocto = vCmdDocto.map { |i| i.to_s.gsub("\t", "  ") }.join("\n")

    vTipo = vCmd[0][0..(vCmd[0].index(/\s/)-1)].to_s
    if vTipo.match(/entry/i)
      vTipo = 'Local Proc'
    elsif vTipo.match(/partner operation/i)
      vTipo = 'Partner Operation'
    elsif vTipo.match(/public operation/i)
      vTipo = 'Public Operation'
    elsif vTipo.match(/operation/i)
      vTipo = 'Operation'
    else
      vTipo = ''
    end
    if !vTipo.nil? && !vTipo.empty?

      if vCmd[0].to_s.split(' ').count <= 2
        begin
          vNmFuncao = "#{vCmd[0][(vCmd[0].index(/\s/)+1)..100].to_s}"
        rescue
          vNmFuncao = "#{vCmd[0][(vCmd[0].index(/\s/)+1)..100].to_s}"
        end
      else
        vNmFuncao = "#{vCmd[0][(vCmd[0].index(/\s/)+1)..100].to_s}"
        vNmFuncao = "#{vNmFuncao[(vNmFuncao.index(/\s/)+1)..100].to_s}"
      end
      vNmFuncao = vNmFuncao[0..(vNmFuncao.index(/\s/))] unless vNmFuncao.index(/\s/).nil?
      vNmFuncao = vNmFuncao.gsub('\n', '')
      vNmFuncao = vNmFuncao.gsub('\r', '')

      vPostString = { 'funcaos': {
        'nm_funcao': vNmFuncao.downcase,
        'cd_componente': vComponente.downcase,
        'tipo': vTipo,
        'codigo': vComandoReal,
        'documentacao': vComandoDocto,
        'cd_empresa': @cd_empresa
        }
      }
      begin
        #if vPostString.to_s.encoding == "ASCII-8BIT"
          vPostString = vPostString.force_encoding("UTF-8").encode("ASCII-8BIT", invalid: :replace, undef: :replace) #.encode("UTF-8", "ASCII-8BIT", invalid: :replace, undef: :replace, replace: "")
        #end
        vPostString = vPostString.to_json.force_encoding("UTF-8").encode("ASCII-8BIT", invalid: :replace, undef: :replace)
      rescue StandardError => e
        Rails.logger.info "AQUI123"
        Rails.logger.info vPostString
        Rails.logger.info '************************'
        Rails.logger.info e.inspect
        Rails.logger.info "********"
        vPostString = vPostString.to_json.force_encoding('UTF-8') #.encode("ASCII-8BIT", invalid: :replace, undef: :replace)
      end
      RestClient.post "#{@servidor_funcao}", JSON.parse(vPostString)
    end
  end
 
  def linhaContem(vLinha)
    ((vLinha.match(/^activate\s.*\".*\"/i) or 
      vLinha.match(/^activate\s.*/i) or
      vLinha.match(/^activate\/.*/i)  or 
      vLinha.match(/activate\/.*/i) or 
      vLinha.match(/activate\s.*/i) or
      vLinha.match(/^newinstance\s.*\".*\"\,/i) or 
      vLinha.match(/^new_instance\s.*\".*\"\,/i) or
      vLinha.match(/^newinstance\/.*\".*\"\,/i) or
      vLinha.match(/^new_instance\/.*\".*\"\,/i) or
      vLinha.match(/^selectdb\s/i) or
      vLinha.match(/^sql.*\,.*\"([a-z]{3})\"/i)))
  end


  def trata_linha_comentario(vLinha, endPosLine)
    vLinha2 = ''
    v2 = vLinha.index(";")
    vLinha2 = vLinha[(v2+1)..endPosLine]

    v2 = 0
    v2 = vLinha2.index("|")
    if !v2.nil?
      vLinha2 = vLinha2[(v2+1)..endPosLine]
    end

    v2 = 0
    v2 = vLinha2.index(/\S/)
    if !v2.nil?
      vLinha2 = vLinha2[v2..endPosLine]
    end

    v2 = 0
    v2 = vLinha2.index('*****')
    if !v2.nil?
      vLinha2 = ''
    end

    v2 = 0
    v2 = vLinha2.index('=====')
    if !v2.nil?
      vLinha2 = ''
    end

    v2 = 0
    v2 = vLinha2.index('---')
    if !v2.nil?
      vLinha2 = ''
    end
    vLinha2[0..endPosLine]
  end

  
  def inicio_fim_linha(linha)
    v1 = linha.index("\n")
    if v1.nil?
      vLinha = linha[26..300]
    else
      v1 -= 1
      vLinha= linha[26..v1]
    end
    [vLinha, v1]
  end


  def processar
    v_dia = Time.now.strftime("%d%m%Y")

    File.open(@nm_arquivo, 'r:UTF-8').each_line.with_index do |li, v_count|
      if v_count > 0
        begin
          v_dia_hora	= Time.new(li.split[5][4..7], li.split[5][2..3], li.split[5][0..1], li.split[6][0..1], li.split[6][2..3])
        rescue
          raise "#{li.split[5]}       #{li.split[6]}"
        end

        if v_dia_hora > @data_ultima_alteracao
          #if li.split[7].include?("aalmf110")
           if v_dia == li.split[5]
             post_arquivo(li.split[7])
           else
             break
           end
          #end
        end
      end
    end
    @arq_importados.close
  end

  def post_arquivo(vArquivo)
    vTipo = ''
    if vArquivo.include?('.cptlst')
      vTipo = 'Componente'
    elsif vArquivo.include?('.menlst')
      vTipo = 'Menu'
    elsif vArquivo.include?('.apslst')
      vTipo = 'StartUpShel'
    end
    if vTipo.empty?
      return nil
    end

    vArquivoLer = "#{@diretorio_listener}/#{vArquivo}"
    vId = nome_arquivo(vArquivoLer)

    RestClient.delete "#{@servidor_http}/#{vId}", {params: 
                      {
                       nome: vId, 
                       cd_empresa: @cd_empresa
                      }
          }

    begin
      RestClient.delete "#{@servidor_funcao}/#{vId}", {params: 
                     {
                      cd_componente: vId,
                      cd_empresa: @cd_empresa
                     }
         }
    rescue Exception => e
      m = File.new("#{Rails.root}/lib/erro_delete_gerado.log", "w")
      m.write "RestClient.delete Funcao\n"
      m.write e.inspect
      m.close
    end
    @arq_importados.write vArquivoLer
    @arq_importados.write "\n"

    vCmdActivate = []
    vIndica = false
    vIndicaFuncao = false
    vCmdFuncao = []
    vCmdLinhaFuncao = []
    vIndicaDocto = false
    vCmdDocto = []
    vIndicaNewInst = false
    dadosNewInstance= []

    f = File.read(vArquivoLer).each_line do |linha|
      if linha[0..0] == '['
        vLinha, posFinalLinha = inicio_fim_linha(linha)
        vLinhaFuncao = vLinha
        vLinha = vLinha.lstrip unless vLinha.nil?
        if !vLinha.nil?
          if vIndica
            vIndica = vLinha.match(/\%\\/) ? true : false
            vLinha = tratar_linha(vLinha)
            if !vLinha.empty?
              vCmdActivate << vLinha
            else
              vIndica = false
              vCmdActivate = []
            end
          else
            if !vLinha.nil?
              if linhaContemNewInstance(vLinha)
                vIndicaNewInst = true
                dadosNewInstance = pegaNomeInstanca(vLinha)
              end
              if (!vLinha.match(/^;/) && vLinha.match(/^entry/i)) or (vLinha.match(/^operation/i) or vLinha.match(/^partner operation/i)  or vLinha.match(/^public operation/i))
                vIndicaFuncao = true
              end
              if vLinha.match(/\;\|/)
                vIndicaDocto = true
              end
              if vIndicaDocto
                if vLinha.match(/\;\|/) or vLinha.match(/\;/)
                  vLinha = trata_linha_comentario(vLinha, posFinalLinha)
                  vCmdDocto << vLinha unless vLinha.nil?
                else
                  vIndicaDocto = false
                end
              end
              if vIndicaFuncao
                vCmdFuncao << vLinha
                vCmdLinhaFuncao << vLinhaFuncao
                if (!vLinha.match(/endw/i) && !vLinha.match(/endf/i) && !vLinha.match(/endi/i) && !vLinha.match(/endv/i) && !vLinha.match(/endp/i) && !vLinha.nil? && !vLinha.match(/^;/)) & (!!(vLinha.match(/^end\s/i)) or !!(vLinha.match(/^end\;/i)) or !!(vLinha.match(/^end/i)))
                  post_funcao(vId, vCmdFuncao, vCmdLinhaFuncao, vCmdDocto)
                  vCmdFuncao = []
                  vCmdLinhaFuncao = []
                  vIndicaFuncao = false
                  vIndicaDocto = false
                  vCmdDocto = []
                end
              end
              if vCmdActivate.any?
                vComando = ""
                vComando = vCmdActivate.map { |i| i.to_s }.join("")
                vComando = vComando.downcase.gsub("$componentname.", "\"#{vId}\".")
                vComando = vComando.downcase.gsub("$instancename.", "\"#{vId}\".")
                vPostString = {'componentes': {'nome': vId, 'linha': vComando, 'cd_empresa': @cd_empresa, 'tipo': vTipo }}
                vPostString = vPostString.to_json
                RestClient.post "#{@servidor_http}", JSON.parse(vPostString)
                vCmdActivate = []
                vIndica = false
              end
              if linhaContem(vLinha)
                if linhaContemActivate(vLinha)
                  if !vLinha.match(/^activate.*/i) and !vLinha.match(/_activate.*/i)
                    vLinha = vLinha.downcase
                    vLinha = vLinha[vLinha.index('activate')..-1]  unless vLinha.index('activate')
                  end
                  if vIndicaNewInst
                    nomeInstancia = dadosNewInstance[2].gsub("\"", "").gsub(",","") unless dadosNewInstance[2].nil?
                    variavelInstancia = dadosNewInstance[1].gsub("\"", "").gsub(",","") unless dadosNewInstance[1].nil?
                    if !nomeInstancia.nil?
                      if nomeInstancia != variavelInstancia and vLinha.include?(nomeInstancia) and variavelInstancia != 'LOAD'
                        vLinha = vLinha.gsub(dadosNewInstance[2].gsub("\"", "").gsub(",",""), "\"#{dadosNewInstance[1].gsub("\"", "").gsub(",","")}\"") unless dadosNewInstance[2].nil?
                        vLinha = vLinha.gsub("\"\"", "\"")
                      end
                    end
                  end
                end
                vIndica = vLinha.match(/\%\\/) ? true : false
                if !vIndica 
                  if (!vLinha[-1, 1].empty? and vLinha[-1, 1] != ")" and vLinha.length >= 248)
                    vIndica = true
                  end
                end
                vLinha = tratar_linha(vLinha)
                if !vLinha.empty?
                  vCmdActivate << vLinha
                else
                  vIndica = false
                  vCmdActivate = []
                end
              end
            end
          end
        end
      end
    end
  end
end
