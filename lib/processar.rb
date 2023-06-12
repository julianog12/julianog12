# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true
#"/var/coamo/unifacedes/r96_coamo_des/proclisting"

class Processar
  require 'open3'
  require "#{Rails.root}/lib/processar_entry_operation"
  require "#{Rails.root}/lib/processar_trigger"
  require "#{Rails.root}/lib/processar_include_proc"

  def initialize(tempresa)
    
    ActiveRecord::Base.establish_connection(YAML.load_file("#{Rails.root}/config/database.yml")[rails_env])

    @cd_empresa = tempresa[:cd_empresa]

    @nm_arquivo = "#{Rails.root}/lib/arquivos_gerados/" + tempresa[:nome_arq_result] + "_#{Time.now.strftime('%d%m%Y%H%M%S')}"
    @nm_arquivos_importados = "#{Rails.root}/lib/arquivos_gerados/" + "#{@cd_empresa}_importados" + "_#{Time.now.strftime('%d_%m_%Y_%H_%M_%S')}"
    begin
      Dir.glob(["#{Rails.root}/lib/arquivos_gerados/" + "#{@cd_empresa}_importados_*",
                "#{Rails.root}/lib/arquivos_gerados/" + tempresa[:nome_arq_result] + "_*"] ).each do |arq|
        File.delete(arq)
      end
    rescue StandardError => e
      Rails.logger.info e.inspect
      puts 'Erro ao tentar remover aquivo /home/user1/search/current/lib/arquivos_gerados/' + "#{@cd_empresa}_importados_*"
      nil
    end

    @extensao_arquivo = (tempresa[:extensao_leitura] == 'all' ? '*' : tempresa[:extensao_leitura])
    @servidor_funcao = tempresa[:servidor_http_funcao]
    @servidor_http = tempresa[:servidor_http]
    @diretorio_listener = tempresa[:diretorio_listener]
    @ultimo_diretorio = tempresa[:ultimo_diretorio]
    @data_ultima_alteracao = ler_arquivo_ultima_alteracao(tempresa[:ultima_alteracao].split(' '))
    puts "gerar_arquivo" if Rails.env=="development"
    gerar_arquivo
    puts "processar" if Rails.env=="development"
    processar
    puts "gravar_arquivo_ultima_alteracao" if Rails.env=="development"
    gravar_arquivo_ultima_alteracao
  end


  def ler_arquivo_ultima_alteracao(data)
    Time.new(data[0], data[1], data[2], data[3], data[4], data[5])
  end

  def gravar_arquivo_ultima_alteracao
    data = Time.now.strftime('%Y %m %d %H %M %S').to_s
    config = Configuracao.where("cd_empresa = '#{@cd_empresa}' and parametro = 'ultima_alteracao'")
    config.update(valor: data)
  end

  def processar
    v_dia = Time.now.strftime("%d%m%Y")
    puts @nm_arquivo  if Rails.env=="development"
    File.open(@nm_arquivo, 'r:UTF-8').each_line.with_index do |li, v_count|
      if v_count.positive?
        item = li.split[7]
        begin
          v_dia_hora = Time.new(li.split[5][4..7], li.split[5][2..3], li.split[5][0..1], li.split[6][0..1], li.split[6][2..3])
        rescue
          raise "#{li.split[5]}       #{li.split[6]}"
        end
        next if item.match(/^aps/i)

        next if v_dia_hora <= @data_ultima_alteracao 

        next if (item[0..(item.index('.')-1)]).size > 8

        #next if !li.split[7].include?("fpagf138")
        if item.length == 15 || item.match(/^arh/i) || item.match(/^ccn/i) ||item.match(/^cnf/i) 
          ProcessarTrigger.new(@cd_empresa,
                            @servidor_funcao, 
                            @servidor_http,
                            @diretorio_listener,
                            @ultimo_diretorio, 
                            li.split[7])
        end
        puts "##Programa  #{item}     #{item.length}" if Rails.env=="development"
        ProcessarEntryOperation.new(@cd_empresa,
                            @nm_arquivos_importados, 
                            @servidor_funcao, 
                            @servidor_http,
                            @diretorio_listener,
                            @ultimo_diretorio, 
                            item)
      end
    end
    ProcessarIncludeProc.new(@cd_empresa, @servidor_funcao)
  end

  def gerar_arquivo
    f = nil
    if @extensao_arquivo == '*'
      f = open("| ls -lt --time-style='+%d%m%Y %H%M' #{@diretorio_listener}")
    else
      f = open("| ls -lt --time-style='+%d%m%Y %H%M' #{@diretorio_listener}/*.#{@extensao_arquivo}")
    end
    a = File.new(@nm_arquivo, 'w')
    a.write f.read.force_encoding('UTF-8')
    a.close
  end

end