class ReportLinhasPorTipoWorker
  include Sidekiq::Worker
  #sidekiq_options queue: :default, retry: true


  def perform(empresa)
    total_linhas = 0
    tot_linhas = 0

    linhas_por_tipo = []
    Funcao.select('tipo, sum(nr_linhas) as total').where("cd_empresa = ? and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')", "#{empresa}").group(:tipo).each do |reg|
      total_linhas += reg.total unless reg.total.nil?
      linhas_por_tipo << { name: reg.tipo, data: reg.total }
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
