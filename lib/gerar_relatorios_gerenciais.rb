# encoding: UTF-8
# Classe para gerar arquivo
# Autor: Juliano Garcia
# frozen_string_literal: true
class GerarRelatoriosGerenciais

  def initialize(empresas)
    processar(empresas)
  end

  def processar(empresas)
    empresas.each do |empresa|
      report_linhas_por_modelo(empresa)
      report_linhas_por_tipo(empresa)
      report_total_objetos(empresa)
    end
  end

  def report_linhas_por_modelo(empresa)
    linhas_por_modelo = []
    Funcao.select("case when substring(cd_componente,1,3) in('ccn', 'arh', 'cnf') 
                        then substring(cd_componente,1,3)
                        else substring(cd_componente,1,4) end
                        as modelo")
          .where('cd_empresa = ? and length(cd_componente) in (7, 8)', "#{empresa}")
          .group("case when substring(cd_componente,1,3) in('ccn', 'arh', 'cnf')
                        then substring(cd_componente,1,3)
                        else substring(cd_componente,1,4) end").each do |reg|
      if reg.modelo.length == 4
        Funcao.where('substring(cd_componente,1,4) = ? and cd_empresa = ? and length(cd_componente) in (7, 8)', reg.modelo, "#{empresa}")
              .select('codigo').each do |regt|
          tot_linhas = 0
          tot_linhas = regt.codigo.count("\n") unless regt.codigo.count("\n").nil?
          if !linhas_por_modelo.nil?  unless regt.codigo.count("\n").nil?
            if linhas_por_modelo.find {|x| x[:name] == reg.modelo}.nil? 
              linhas_por_modelo << { name: reg.modelo, data: tot_linhas }
            else
              linhas_por_modelo.find{|h| h[:name] == reg.modelo}[:data] += tot_linhas
            end
          else
            linhas_por_modelo << { name: reg.modelo, data: tot_linhas }
          end
        end
      else

        Funcao.where('substring(cd_componente,1,3) = ? and cd_empresa = ? and length(cd_componente) in (7,8)', reg.modelo, "#{empresa}").select('codigo').each do |regt|
          tot_linhas = 0
          tot_linhas = regt.codigo.count("\n") unless regt.codigo.count("\n").nil?
          if !linhas_por_modelo.nil? 
            if linhas_por_modelo.find {|x| x[:name] == reg.modelo}.nil? 
              linhas_por_modelo << { name: reg.modelo, data: tot_linhas }
            else
              linhas_por_modelo.find{|h| h[:name] == reg.modelo}[:data] += tot_linhas
            end
          else
            linhas_por_modelo << { name: reg.modelo, data: tot_linhas }
          end
        end
      end
    end
    tot_linhas_por_modelo = {}
    linhas_por_modelo.each do |it|
      tot_linhas_por_modelo[it[:name]] = it[:data]
    end

    unless File.directory?("#{Rails.root.join('public')}/reports")
      Dir.mkdir "#{Rails.root.join('public')}/reports"
    end
    out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_linhas_por_modelo_report.rep", 'w')
    out_file.puts tot_linhas_por_modelo
    out_file.close
  end

  def report_linhas_por_tipo(empresa)
    total_linhas = 0
    tot_linhas = 0

    linhas_por_tipo = []
    Funcao.select('tipo').where('cd_empresa = ? and length(cd_componente) in(7,8)', "#{empresa}").group(:tipo).each do |reg|
      Funcao.where('tipo = ? and cd_empresa = ? and length(cd_componente) in(7,8)', reg.tipo, "#{empresa}").select('codigo').each do |regt|
        tot_linhas = 0
        tot_linhas = regt.codigo.count("\n") unless regt.codigo.count("\n").nil?
        total_linhas += tot_linhas
        if !linhas_por_tipo.nil? 
          if linhas_por_tipo.find {|x| x[:name] == reg.tipo}.nil? 
            linhas_por_tipo << { name: reg.tipo, data: tot_linhas }
          else
            linhas_por_tipo.find{|h| h[:name] == reg.tipo}[:data] += tot_linhas
          end
        else
          linhas_por_tipo << { name: reg.tipo, data: tot_linhas }
        end
      end
    end
    tot_linhas_por_tipo = {}
    linhas_por_tipo.each do |it|
      tot_linhas_por_tipo[it[:name]] = it[:data]
    end

    unless File.directory?("#{Rails.root.join('public')}/reports")
      Dir.mkdir "#{Rails.root.join('public')}/reports"
    end

    out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_linhas_por_tipo_report.rep", 'w')
    out_file.puts tot_linhas_por_tipo
    out_file.close

    out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_total_linhas_geral_report.rep", 'w')
    out_file.puts total_linhas
    out_file.close
  end

  def report_total_objetos(empresa)
    total_componentes = Funcao.where("cd_empresa = ?", "#{empresa} and length(cd_componente) in(7,8)").distinct.pluck(:cd_componente).count
    total_includes = Funcao.where("cd_empresa = ? and tipo =  'include' and length(cd_componente) in(7,8)", "#{empresa}").count
    total_operations = Funcao.where("cd_empresa = ? and tipo =  'operation' and length(cd_componente) in(7,8)", "#{empresa}").count
    total_execs = Funcao.where("cd_empresa = ? and tipo =  'trigger-form' and nm_funcao = 'EXEC' and length(cd_componente) in(7,8)", "#{empresa}").count

    dados = {componentes: total_componentes, includes: total_includes, operations: total_operations, exec: total_execs}

    unless File.directory?("#{Rails.root.join('public')}/reports")
      Dir.mkdir "#{Rails.root.join('public')}/reports"
    end
    out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_total_objetos_de_implementacao_report.rep", 'w')
    out_file.puts dados
    out_file.close
    
  end

end
