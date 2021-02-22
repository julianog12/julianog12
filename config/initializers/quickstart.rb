require 'rufus-scheduler'
require 'rest-client'
require "#{Rails.root}/lib/processar.rb"

scheduler = Rufus::Scheduler.new

arquivos_yml = Dir.glob("#{Rails.root}/lib/*.yml")

arquivos_yml.each.with_index do |arq, index|

  scheduler.in '1s' do
    Processar.new(arq)
  end

  #scheduler.cron '02 09 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(arq)
  #end

  #scheduler.cron '24 12 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(arq)
  #end

  #scheduler.cron '03 16 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(arq)
  #end

  #scheduler.cron '30 19 * * 1-5 America/Sao_Paulo' do
  #  Processar.new(arq)
  #end

end
