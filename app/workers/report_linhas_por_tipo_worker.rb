class ReportLinhasPorTipoWorker
  include Sidekiq::Worker
  #sidekiq_options queue: :default, retry: true


  def perform(empresa)
    total_linhas = 0
    tot_linhas = 0

    linhas_por_tipo = []
    Funcao.select('tipo').where("cd_empresa = ? and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')", "#{empresa}").group(:tipo).each do |reg|
      Funcao.where("tipo = ? and cd_empresa = ? and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')", reg.tipo, "#{empresa}").select('codigo').each do |regt|
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
end
