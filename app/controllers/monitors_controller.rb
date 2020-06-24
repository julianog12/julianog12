class MonitorsController < ApplicationController
  
  def index
    if params[:data_inicial].present? && params[:data_final].present?
      target_client = Elasticsearch::Client.new url: 'http://172.17.82.27:8080/prd-uniface-monitor-0620', log: true

      consulta = []

      datas = {  range: {timestamp: {  gte: "#{params[:data_inicial]}",  lte: "#{params[:data_inicial]}"}  }}
      usuario = {  match: {ouser_oracle: "#{params[:ouser_oracle]}",  }} if params[:ouser_oracle].present?
      sid = {  match: {sid_oracle: "#{params[:sid_oracle]}",  }} if params[:sid_oracle].present?

      componente = {  match: {nm_componente: "#{params[:nm_componente]}",  }} if params[:nm_componente].present?

      consulta << datas
      consulta << usuario unless usuario.nil?
      consulta << componente unless componente.nil?
      consulta << sid unless sid.nil?

      response = target_client.search body:
                      {from: 0, size: 10000,query:
                         {bool:
                             {
                               must: consulta  
                            }
                          }
                       }

      dados =  response["hits"]["hits"]
	    tab_array = []

      dados.each do |item|
        v1 = item["_source"]["timestamp"][0..3]
        v2 = item["_source"]["timestamp"][5..6]
        v3 = item["_source"]["timestamp"][8..9]
  
        v4 = item["_source"]["timestamp"][11..12].to_i
        v4 -= 3
        v5 = item["_source"]["timestamp"][14..15]
        v6 = item["_source"]["timestamp"][17..18]
  
        date_and_time = '%d-%m-%Y %H:%M:%S'
        data_hora = DateTime.parse("#{v1}-#{v2}-#{v3} #{v4.to_s}:#{v5}:#{v6}", date_and_time)
        dado = {:sid => item["_source"]["sid_oracle"], :data_hora => data_hora.strftime('%d/%m/%Y %H:%M:%S'), :estacao => item["_source"]["estacao"], :servidor => item["_source"]["host"], :user => item["_source"]["ouser_oracle"], :componente => item["_source"]["nm_componente"], :componente_pai => item["_source"]["nm_intancia_pai"]}
        tab_array << dado
      end ;nil

      #Tirando Duplicados
      @dados_monitor= tab_array.uniq { |topic| topic.values }

    end
  
  end
end