# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true

class GerarArquivo
  require 'open3'
  require "#{Rails.root}/lib/canivete.rb"

  def initialize(caminho_config)
    @caminho = caminho_config
    @arq_yml = YAML.safe_load(File.open(@caminho))
    @cd_empresa = @arq_yml['ambiente']['empresa']

    @nm_arquivo = "#{Rails.root}/lib/arquivos_gerados/" + @arq_yml['geral']['nome_arq_result'] + "_#{Time.now.strftime('%d%m%Y%H%M%S')}"
    @nm_arquivos_importados = "#{Rails.root}/lib/arquivos_gerados/" + "#{@cd_empresa}_importados" + "_#{Time.now.strftime('%d_%m_%Y_%H_%M_%S')}"

    begin
      File.delete("#{Rails.root}/lib/arquivos_gerados/" + "#{@cd_empresa}_importados_*")
    rescue StandardError => e
      Rails.logger.info e.inspect
      nil
    end

    @extensao_arquivo = (@arq_yml['ambiente']['extensao_leitura'] == 'all' ? '*' : @arq_yml['ambiente']['extensao_leitura'])
    @servidor_funcao = @arq_yml['geral']['servidor_http_funcao']
    @servidor_http = @arq_yml['geral']['servidor_http']
    @diretorio_listener = @arq_yml['ambiente']['diretorio_listener']
    @ultimo_diretorio = @arq_yml['geral']['ultimo_diretorio']
    @data_ultima_alteracao = ler_arquivo_ultima_alteracao(@arq_yml['geral']['ultima_alteracao'].split(' '))

    gerar_arquivo
    processar

    begin
      File.delete(@nm_arquivo)
    rescue StandardError => e
      Rails.logger.info e
    end
    gravar_arquivo_ultima_alteracao
  end

  def ler_arquivo_ultima_alteracao(data)
    Time.new(data[0], data[1], data[2], data[3], data[4], data[5])
  end

  def gravar_arquivo_ultima_alteracao
    data = Time.now.strftime('%Y %m %d %H %M %S').to_s
    @arq_yml['geral']['ultima_alteracao'] = data
    File.open(@caminho, 'w') { |f| f.write @arq_yml.to_yaml }
  end

  def linhaContemNewInstance(v_linha)
    v = (v_linha.match(/^newinstance\s.*\".*\"\,/i) || v_linha.match(/^new_instance\s.*\".*\"\,/i) || v_linha.match(/^newinstance\/.*\".*\"\,/i))
    if v
      begin
        dados = v_linha.scan(/\S+/)
        v = dados[1].downcase != dados[2].downcase unless dados[1].nil? && dados[2].nil?
      rescue StandardError => e
        Rails.logger.info 'AAAEEEE'
        Rails.logger.info dados.inspect
        Rails.logger.info e
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

  def gerar_arquivo
    f = nil
    if @extensao_arquivo == '*'
      f = open("| ls -lt --time-style='+%d%m%Y %H%M' #{@diretorio_listener}/")
    else
      f = open("| ls -lt --time-style='+%d%m%Y %H%M' #{@diretorio_listener}/*.#{@extensao_arquivo}")
    end
    a = File.new(@nm_arquivo, 'w')
    a.write f.read.force_encoding('UTF-8')
    a.close
    @arq_importados = File.new(@nm_arquivos_importados, 'w')
  end


  def tipo_funcao(v_cmd)
    case v_cmd
    when /entry/i
      'Local Proc'
    when /partner operation/i
      'Partner Operation'
    when /public operation/i
      'Public Operation'
    when /operation/i
      'Operation'
    else
      ''
    end
  end

  def post_funcao(v_componente, v_cmd, v_cmd_real, v_cmd_docto)
    v_comando_real = v_cmd_real.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")
    v_comando_docto = v_cmd_docto.map { |i| i.to_s.gsub("\t", '  ') }.join("\n")

    v_tipo = tipo_funcao(v_cmd[0][0..(v_cmd[0].index(/\s/) -1)].to_s)
    
    if !v_tipo.nil? && !v_tipo.empty?
      if v_cmd[0].to_s.split(' ').count <= 2
        begin
          v_nm_funcao = "#{v_cmd[0][(v_cmd[0].index(/\s/)+1)..100]}"
        rescue StandardError => e
          puts e.inspet
          v_nm_funcao = "#{v_cmd[0][(v_cmd[0].index(/\s/)+1)..100]}"
        end
      else
        v_nm_funcao = "#{v_cmd[0][(v_cmd[0].index(/\s/)+1)..100]}"
        v_nm_funcao = "#{v_nm_funcao[(v_nm_funcao.index(/\s/)+1)..100]}"
      end
      v_nm_funcao = v_nm_funcao[0..(v_nm_funcao.index(/\s/))] unless v_nm_funcao.index(/\s/).nil?
      v_nm_funcao = v_nm_funcao.gsub('\n', '')
      v_nm_funcao = v_nm_funcao.gsub('\r', '')

      v_encode_salvo = Encoding.default_external

      Encoding.default_internal = Encoding::UTF_8
	  
      v_post_string = { 'funcaos': {
        'nm_funcao': v_nm_funcao.downcase,
        'cd_componente': v_componente.downcase,
        'tipo': v_tipo,
        'codigo': v_comando_real,
        'documentacao': v_comando_docto,
        'cd_empresa': @cd_empresa
        }
      }

      begin
        #v_post_string = v_post_string.to_json.force_encoding('UTF-8')
		
		v_post_string = v_post_string.to_json.force_encoding('UTF-8')
		Encoding.default_external = eval("Encoding::#{v_post_string.encoding.name.gsub('-','_')}")
		
        RestClient.post "#{@servidor_funcao}", JSON.parse(v_post_string)
        Encoding.default_external = v_encode_salvo
      rescue StandardError => e
        Rails.logger.info 'AQUI123'
		Rails.logger.info v_comando_real.encoding
		Rails.logger.info v_comando_docto.encoding
		Encoding.default_external = v_encode_salvo
        Rails.logger.info Encoding.default_internal
        Rails.logger.info Encoding.default_external
        Rails.logger.info "Encoding do arquivo #{v_post_string.to_s.encoding}"
        Rails.logger.info '************************'
        Rails.logger.info e.inspect
        Rails.logger.info '********'
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
    v2 = v_linha.index(";")
    v_linha2 = v_linha[(v2+1)..endPosLine]

    v2 = v_linha2.index("|")
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


  def processar
    v_dia = Time.now.strftime("%d%m%Y")

    File.open(@nm_arquivo, 'r:UTF-8').each_line.with_index do |li, v_count|
      if v_count.positive?
        begin
          v_dia_hora	= Time.new(li.split[5][4..7], li.split[5][2..3], li.split[5][0..1], li.split[6][0..1], li.split[6][2..3])
        rescue
          raise "#{li.split[5]}       #{li.split[6]}"
        end

        if v_dia_hora > @data_ultima_alteracao
          break if v_dia != li.split[5]
          post_arquivo(li.split[7])
        end
      end
    end
    @arq_importados.close
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

  def deletar_dados(v_id)
    RestClient.delete "#{@servidor_http}/#{v_id}", {params: 
      {
       nome: v_id, 
       cd_empresa: @cd_empresa
      }
    }
    RestClient.delete "#{@servidor_funcao}/#{v_id}", {params: 
      {
       cd_componente: v_id,
       cd_empresa: @cd_empresa
      }
    }
  end


  def post_arquivo(v_arquivo)

    return nil if tipo_arquivo(v_arquivo).nil?
    v_arquivo_ler = "#{@diretorio_listener}/#{v_arquivo}"
    v_id = nome_arquivo(v_arquivo_ler)

    begin
      deletar_dados(v_id)
    rescue StandardError => e
      Rails.logger.info 'Erro deletar funcao deletar_dados'
      Rails.logger.info e
      return nil
    end

    @arq_importados.write v_arquivo_ler
    @arq_importados.write "\n"

    v_cmd_activate = []
    v_indica = false
    v_indica_funcao = false
    v_cmd_funcao = []
    v_cmd_linha_funcao = []
    v_indica_docto = false
    v_cmd_docto = []
    v_indica_new_inst = false
    dados_new_instance= []

    File.read(v_arquivo_ler).each_line do |linha|
      next unless linha[0..0] == '['
      v_linha, posFinalLinha = inicio_fim_linha(linha)
      v_linha_funcao = v_linha
      v_linha = v_linha.lstrip unless v_linha.nil?
      unless v_linha.nil?
        if v_indica
          v_indica = v_linha.match(/\%\\/) ? true : false
          v_linha = tratar_linha(v_linha)
          if !v_linha.empty?
            v_cmd_activate << v_linha
          else
            v_indica = false
            v_cmd_activate = []
          end
        else
          unless v_linha.nil?
            if linhaContemNewInstance(v_linha)
              v_indica_new_inst = true
              dados_new_instance = pegaNomeInstanca(v_linha)
            end
            if (!v_linha.match(/^;/) && v_linha.match(/^entry/i)) || (v_linha.match(/^operation/i) || v_linha.match(/^partner operation/i) || v_linha.match(/^public operation/i))
              v_indica_funcao = true
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
            if v_indica_funcao
              v_cmd_funcao << v_linha
              v_cmd_linha_funcao << v_linha_funcao
              if (!v_linha.match(/endw/i) && !v_linha.match(/endf/i) && !v_linha.match(/endi/i) && !v_linha.match(/endv/i) && !v_linha.match(/endp/i) && !v_linha.nil? && !v_linha.match(/^;/)) & (!!(v_linha.match(/^end\s/i)) || !!(v_linha.match(/^end\;/i)) || !!(v_linha.match(/^end/i)))
                post_funcao(v_id, v_cmd_funcao, v_cmd_linha_funcao, v_cmd_docto)
                v_cmd_funcao = []
                v_cmd_linha_funcao = []
                v_indica_funcao = false
                v_indica_docto = false
                v_cmd_docto = []
              end
            end
            if v_cmd_activate.any?
              v_comando = v_cmd_activate.map(&:to_s).join('')
              v_comando = v_comando.downcase.gsub('$componentname.', "\"#{v_id}\".")
              v_comando = v_comando.downcase.gsub('"$instancename.', "\"#{v_id}\".")
              v_comando = v_comando.downcase.gsub('%%$componentname', "#{v_id}")
              v_comando = v_comando.downcase.gsub('%%$instancename', "#{v_id}")
              v_post_string = {'componentes': {'nome': v_id, 'linha': v_comando, 'cd_empresa': @cd_empresa, 'tipo': tipo_arquivo(v_arquivo) }}
              v_post_string = v_post_string.to_json
              RestClient.post "#{@servidor_http}", JSON.parse(v_post_string)
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
                      v_linha = v_linha.gsub(dados_new_instance[2].gsub("\"", "").gsub(",",""), "\"#{dados_new_instance[1].gsub("\"", '').gsub(",",'')}\"") unless dados_new_instance[2].nil?
                      v_linha = v_linha.gsub("\"\"", "\"")
                    end
                  end
                end
              end
              v_indica = v_linha.match(/\%\\/) ? true : false
              if !v_indica 
                if (!v_linha[-1, 1].empty? and v_linha[-1, 1] != ")" and v_linha.length >= 248)
                  v_indica = true
                end
              end
              v_linha = tratar_linha(v_linha)
              if !v_linha.empty?
                v_cmd_activate << v_linha
              else
                v_indica = false
                v_cmd_activate = []
              end
            end
          end
        end
      end
    end
  end
end
