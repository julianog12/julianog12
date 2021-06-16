# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true
#"/var/coamo/unifacedes/r96_coamo_des/proclisting"


class ProcessarDiferencas
  require 'open3'
  require "#{Rails.root}/lib/processar_entry_operation"
  require "#{Rails.root}/lib/processar_trigger"
  require "#{Rails.root}/lib/processar_include_proc"

  def initialize(tempresa)

    @cd_empresa = tempresa[:cd_empresa]

    @nm_arquivo = "#{Rails.root}/falta_componentes_#{@cd_empresa}.txt"

    @extensao_arquivo = (tempresa[:extensao_leitura] == 'all' ? '*' : tempresa[:extensao_leitura])
    @servidor_funcao = tempresa[:servidor_http_funcao]
    @servidor_http = tempresa[:servidor_http]
    @diretorio_listener = tempresa[:diretorio_listener]
    @ultimo_diretorio = tempresa[:ultimo_diretorio]

    processar_diferencas

  end


  def processar_diferencas
    File.open(@nm_arquivo, 'r:UTF-8').each_line.with_index do |li, v_count|
      item = li
      Rails.logger.info "#{li}.cptlst"
      item = item[0..(item.index(/\n/)-1)].strip
      item = item.strip
      item = "#{item}.cptlst"
      next unless File.exist?("#{@diretorio_listener}/#{item}")
      next if item.nil?
      next if item.match(/^aps/i) || (item[0..(item.index('.')-1)]).size > 8


      if v_count.positive?
        if item.length == 15 ||
          item.match(/^arh/i) ||
          item.match(/^ccn/i) ||
          item.match(/^cnf/i)
          puts "##ENTROU #{item}  #{item.length}"
          ProcessarTrigger.new(@cd_empresa,
                             @servidor_funcao,
                             @servidor_http,
                             @diretorio_listener,
                             @ultimo_diretorio,
                             item)
        end

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