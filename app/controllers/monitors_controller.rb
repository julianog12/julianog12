class MonitorsController < ApplicationController
  respond_to :json, :html, :js
  

  def index
    if params[:data_inicial].present? && params[:data_final].present?

      v_data_inicial = formata_data(params[:data_inicial], "+", '%Y-%m-%dT%H:%M')
      v_data_final =  formata_data(params[:data_final], "+", '%Y-%m-%dT%H:%M')

      #api-authentication = cnRrZC0za0J4c19jXzljajlLZnE6WF9TRFJUdjlTQ2l3U1FoZE9za2VZUQ==

      target_client = Elasticsearch::Client.new(
              url: "https://elk.coamo.com.br/prd-uniface-monitor",
              api_key: "YlJEQnZYMEI0YWl2a0F1c2tmWlE6VUMzTldHYzJUeXVXdkR2a19PYXlyZw==",
              log: true)

      consulta = []

      datas = {  range: {timestamp: {  gte: "#{v_data_inicial}",  lte: "#{v_data_final}"}  }}
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

        data_hora = formata_data(item["_source"]["timestamp"], "-", '%d/%m/%Y %H:%M:%S')
        dado = {:sid => item["_source"]["sid_oracle"], :data_hora => data_hora, :estacao => item["_source"]["estacao"], :inst_oracle => item["_source"]["no_oracle"], :servidor => item["_source"]["host"], :user => item["_source"]["ouser_oracle"], :componente => item["_source"]["nm_componente"], :componente_pai => item["_source"]["nm_instancia_pai"]} 
        tab_array << dado

      end

      #Tirando Duplicados
      @dados_monitor= tab_array.uniq { |topic| topic.values }
      respond_with(@dados_monitor)
    else
      flash.now[:notice] = "Os campos data Inicial, Data Final e Mês/Ano são obrigatórios!"
    end
  
  end

  def formata_data(data, sinal, formato)
    v1 = data[0..3]
    v2 = data[5..6]
    v3 = data[8..9]
  
    v4 = data[11..12].to_i
    if sinal == "-"
      v4 -= 3
    elsif sinal == "+"
      v4 += 3
    end
    v5 = data[14..15]
    v6 = data[17..18]

    #date_and_time = '%d-%m-%Y %H:%M:%S'
    data_hora = DateTime.parse("#{v1}-#{v2}-#{v3} #{v4.to_s}:#{v5}:#{v6}", formato)
    data_hora.strftime(formato)
  end

end