class ReportObjetosImplModeloWorker
  include Sidekiq::Worker
  #sidekiq_options queue: :low, retry: true

  def perform(empresa)
    linhas = []
    Funcao.select("case when substring(cd_componente,1,3) in('ccn', 'arh', 'cnf')
                        then substring(cd_componente,1,3)
                        else substring(cd_componente,1,4) end
                        as modelo")
          .where("cd_empresa = ? and length(cd_componente) in (7, 8) and substring(cd_componente,1,4) not in ('acon', 'acre')", empresa.to_s)
          .group("case when substring(cd_componente,1,3) in('ccn', 'arh', 'cnf')
                    then substring(cd_componente,1,3)
                    else substring(cd_componente,1,4)
                    end").each do |reg|
      if reg.modelo.length == 4
        total_componentes = Funcao.where('cd_empresa = ? and 
                                          length(cd_componente) in(7,8) and
                                          substring(cd_componente,1,4) = ?',
                                         empresa.to_s, 
                                         reg.modelo).distinct.pluck(:cd_componente).count
        total_operations = Funcao.where("cd_empresa = ? and 
                                         tipo = 'operation' and
                                         length(cd_componente) in(7,8) and
                                         substring(cd_componente,1,4) = ?",
                                         empresa.to_s,
                                         reg.modelo).count
        dados = {name: reg.modelo, 
                  data: {componentes: total_componentes, operations: total_operations}
                }
      else
        total_componentes = Funcao.where("cd_empresa = ? and length(cd_componente) in(7,8) and substring(cd_componente,1,3) = ?", "#{empresa}", reg.modelo).distinct.pluck(:cd_componente).count
        total_operations = Funcao.where("cd_empresa = ? and tipo =  'operation' and length(cd_componente) in(7,8) and substring(cd_componente,1,4) = ?", "#{empresa}", reg.modelo).count
          dados = {name: reg.modelo, 
                    data: {componentes: total_componentes, operations: total_operations}
                  }
      end
      linhas << dados
    end
    unless File.directory?("#{Rails.root.join('public')}/reports")
      Dir.mkdir "#{Rails.root.join('public')}/reports"
    end
    out_file = File.new("#{Rails.root.join('public')}/reports/#{empresa}_total_objetos_de_implementacao_modelo_report.rep", 'w')
    out_file.puts linhas
    out_file.close
  end
 
end
