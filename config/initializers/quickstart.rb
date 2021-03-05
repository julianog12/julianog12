require 'rufus-scheduler'
require 'rest-client'
require "#{Rails.root}/lib/processar.rb"
require "#{Rails.root}/lib/processar_tudo.rb"
require "#{Rails.root}/lib/gerar_relatorios_gerenciais.rb"

scheduler = Rufus::Scheduler.new

empresas = [1,2,3,4]

scheduler.cron '42 11 * * 1-5 America/Sao_Paulo', :job => true do
  GerarRelatoriosGerenciais.new(empresas)
end

scheduler.cron '00 20 * * 1-5 America/Sao_Paulo', :job => true do
  GerarRelatoriosGerenciais.new(empresas)
end

#scheduler.in '1s' do
#  ProcessarTudo.new("#{Rails.root}/lib/leitura_coamo_desenv.yml")
#end

empresas.each do |empresa|
  dados = Configuracao.where("cd_empresa = '#{empresa}'")
  tempresa = dados.map{ |c| [c.parametro.to_sym, c.valor] }.to_h
  tempresa[:cd_empresa] = dados.first.cd_empresa

  scheduler.cron '30 09 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

  scheduler.cron '15 12 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

  scheduler.cron '30 15 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

  scheduler.cron '30 19 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

end
