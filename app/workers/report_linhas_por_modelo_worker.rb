class ReportLinhasPorModeloWorker
  include Sidekiq::Worker
  #sidekiq_options queue: :critical, retry: true

  def perform(empresa)
    linhas_por_modelo = []
    Funcao.select("nm_modelo, sum(nr_linhas) as total")
          .where("cd_empresa = ? and length(cd_componente) in (7, 8) and substring(cd_componente,1,4) not in ('acon', 'acre')", "#{empresa}")
          .group("nm_modelo").each do |reg|
      linhas_por_modelo << { name: reg.nm_modelo, data: reg.total }
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

end
