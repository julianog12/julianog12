require 'rufus-scheduler'
require 'rest-client'
require "#{Rails.root}/lib/processar.rb"
require "#{Rails.root}/lib/processar_tudo.rb"

scheduler = Rufus::Scheduler.new

arquivos_yml = Dir.glob("#{Rails.root}/lib/*.yml")

scheduler.in '1s' do
  ProcessarTudo.new("#{Rails.root}/lib/leitura_coamo_desenv.yml")
end

arquivos_yml.each.with_index do |arq, index|

  next if arq.include?("leitura_coamo_desenv.yml")
  #scheduler.cron '02 09 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(arq)
  #end

  scheduler.cron '00 11 * * 1-5 America/Sao_Paulo' do
    Processar.new(arq)
  end

  scheduler.cron '30 15 * * 1-5 America/Sao_Paulo' do
    Processar.new(arq)
  end

  #scheduler.cron '30 19 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(arq)
  #end

end
