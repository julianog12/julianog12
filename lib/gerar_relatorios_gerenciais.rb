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
    ReportLinhasPorModeloWorker.perform_async(empresa)
  end

  def report_linhas_por_tipo(empresa)
    ReportLinhasPorTipoWorker.perform_async(empresa)
  end

  def report_total_objetos(empresa)
    ReportObjetosImplementacaoWorker.perform_async(empresa)
  end

end
