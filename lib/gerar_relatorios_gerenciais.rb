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
      linhas_por_modelo = []
      Funcao.select('substring(cd_componente,1,4) as modelo')
            .where('cd_empresa = ? and length(cd_componente) = 8', "#{empresa}").group('substring(cd_componente,1,4)').each do |reg|
        Funcao.where('substring(cd_componente,1,4) = ? and cd_empresa = ? and length(cd_componente) = 8', reg.modelo, "#{empresa}").select('codigo').each do |regt|
          tot_linhas = regt.codigo.count("\n")
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
      tot_linhas_por_modelo = {}
      linhas_por_modelo.each do |it|
        tot_linhas_por_modelo[it[:name]] = it[:data]
      end

      unless File.directory?("#{Rails.root.join('public')}/reports")
        Dir.mkdir "#{Rails.root.join('public')}/reports"
      end
      data_hora = Time.now.strftime("%d%m%y_%H%M%S")
      out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_report.rep", 'w')
      out_file.puts tot_linhas_por_modelo
      out_file.close
    end
  end

end
