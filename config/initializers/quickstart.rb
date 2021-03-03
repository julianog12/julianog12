require 'rufus-scheduler'
require 'rest-client'
require "#{Rails.root}/lib/processar.rb"
require "#{Rails.root}/lib/processar_tudo.rb"

scheduler = Rufus::Scheduler.new

#arquivos_yml = Dir.glob("#{Rails.root}/lib/*.yml")

empresas = [1,2,3,4]
#empresas = [4]

#scheduler.in '1s' do
#  ProcessarTudo.new("#{Rails.root}/lib/leitura_coamo_desenv.yml")
#end

#arquivos_yml.each.with_index do |arq, index|
empresas.each do |empresa|
  #next if Rails.env == 'development'
  
  scheduler.cron '30 09 * * 1-5 America/Sao_Paulo' do
    Processar.new(empresa)
  end

  scheduler.cron '15 12 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

  scheduler.cron '30 15 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

  scheduler.cron '00 19 * * 1-5 America/Sao_Paulo' do
    Processar.new(tempresa)
  end

end