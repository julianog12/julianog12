require 'rufus-scheduler'
require 'rest-client'
require "#{Rails.root}/lib/processar.rb"
require "#{Rails.root}/lib/processar_tudo.rb"
require "#{Rails.root}/lib/gerar_relatorios_gerenciais.rb"

return(0)

scheduler = Rufus::Scheduler.new

empresas = []
if Rails.env == 'production'
  empresas = [5,4,3,2]  #1
  scheduler.cron '00 21 * * 1-5 America/Sao_Paulo', :job => true do
    GerarRelatoriosGerenciais.new([4,2])
  end
else
  empresas = [1]
  #scheduler.in '1s' do
  #  GerarRelatoriosGerenciais.new([4])
  #end
end

#scheduler.in '1s' do
#  empresa = 1
#  dados = Configuracao.where("cd_empresa = '#{empresa}'")
#  tempresa = dados.map{ |c| [c.parametro.to_sym, c.valor] }.to_h
#  tempresa[:cd_empresa] = dados.first.cd_empresa
#  ProcessarTudo.new(tempresa)
#end

empresas.each do |empresa|
  dados = Configuracao.where("cd_empresa = '#{empresa}'")
  tempresa = dados.map{ |c| [c.parametro.to_sym, c.valor] }.to_h
  tempresa[:cd_empresa] = dados.first.cd_empresa

  #scheduler.cron '30 09 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(tempresa)
  #end

  scheduler.cron '15 12 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

  #scheduler.cron '30 15 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(tempresa)
  #end

  scheduler.cron '30 19 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

end
