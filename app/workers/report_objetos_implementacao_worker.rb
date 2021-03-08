class ReportObjetosImplementacaoWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: true

  def perform(empresa)
    total_componentes = Funcao.where("cd_empresa = ? and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')", "#{empresa}").distinct.pluck(:cd_componente).count
    total_includes = Funcao.where("cd_empresa = ? and tipo =  'include'", "#{empresa}").count
    total_operations = Funcao.where("cd_empresa = ? and tipo =  'operation' and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')", "#{empresa}").count
    total_execs = Funcao.where("cd_empresa = ? and tipo =  'trigger-form' and nm_funcao = 'EXEC' and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')", "#{empresa}").count

    dados = {componentes: total_componentes, includes: total_includes, operations: total_operations, exec: total_execs}

    unless File.directory?("#{Rails.root.join('public')}/reports")
      Dir.mkdir "#{Rails.root.join('public')}/reports"
    end
    out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_total_objetos_de_implementacao_report.rep", 'w')
    out_file.puts dados
    out_file.close
  end
end
