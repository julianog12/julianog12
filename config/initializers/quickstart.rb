require 'rufus-scheduler'
require 'rest-client'
require "#{Rails.root}/lib/processar.rb"
require "#{Rails.root}/lib/processar_tudo.rb"
require "#{Rails.root}/lib/gerar_relatorios_gerenciais.rb"

return(0)

scheduler = Rufus::Scheduler.new

#As empresas 1 e 2 foram desativadas. Agora da coamo para o uniface 10 é 6 e 7

empresas = []
if Rails.env == 'production'
  empresas = [5,7,6,9,8]
  scheduler.cron '00 21 * * 1-5 America/Sao_Paulo', :job => true do
    GerarRelatoriosGerenciais.new([4,2])
  end
else
  empresas = [6]
  #scheduler.in '1s' do
  #  GerarRelatoriosGerenciais.new([4])
  #end
end

scheduler.in '1s' do
  empresa = 9
  dados = Configuracao.where("cd_empresa = '#{empresa}'")
  tempresa = dados.map{ |c| [c.parametro.to_sym, c.valor] }.to_h
  tempresa[:cd_empresa] = dados.first.cd_empresa
  ProcessarTudo.new(tempresa)
end

return(0)

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
