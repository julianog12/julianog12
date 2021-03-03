class PainelController < ApplicationController

  def index
    return unless params[:cd_empresa].present?

    @total_linhas = 0
    tot_linhas = 0

    linhas_por_modelo = []
    Funcao.select('substring(cd_componente,1,4) as modelo')
           .where('cd_empresa = ? and length(cd_componente) = 8', "#{params[:cd_empresa]}").group("substring(cd_componente,1,4)").each do |reg|
      Funcao.where('substring(cd_componente,1,4) = ? and cd_empresa = ? and length(cd_componente) = 8', reg.modelo, "#{params[:cd_empresa]}").select('codigo').each do |regt|
        tot_linhas = regt.codigo.count("\n")
        if !linhas_por_modelo.nil? 
          if linhas_por_modelo.find {|x| x[:name] == reg.modelo}.nil? 
            linhas_por_modelo << { name: reg.modelo, data: tot_linhas }
          else
            linhas_por_modelo.find{|h| h[:name] == reg.modelo}[:data] += tot_linhas
          end
        else
          linhas_por_modelo << { name: reg.modelo, data: tot_linhas }
        end
     end
    end
    @tot_linhas_por_modelo = {}
    linhas_por_modelo.each do |it|
      @tot_linhas_por_modelo[it[:name]] = it[:data]
    end

    linhas_por_tipo = []
    Funcao.select('tipo').where('cd_empresa = ?', "#{params[:cd_empresa]}").group(:tipo).each do |reg|
      Funcao.where('tipo = ? and cd_empresa = ?', reg.tipo, "#{params[:cd_empresa]}").select('codigo').each do |regt|
        tot_linhas = regt.codigo.count("\n")
        @total_linhas += tot_linhas
        if !linhas_por_tipo.nil? 
          if linhas_por_tipo.find {|x| x[:name] == reg.tipo}.nil? 
            linhas_por_tipo << { name: reg.tipo, data: tot_linhas }
          else
            linhas_por_tipo.find{|h| h[:name] == reg.tipo}[:data] += tot_linhas
          end
        else
          linhas_por_tipo << { name: reg.tipo, data: tot_linhas }
        end
     end
    end
    @tot_linhas_por_tipo = {}
    linhas_por_tipo.each do |it|
      @tot_linhas_por_tipo[it[:name]] = it[:data]
    end

    return unless params[:data_inicial].present? && params[:data_final].present? && params[:cd_empresa].present?

    v_data_inicial = formata_data(params[:data_inicial], '+', '%Y-%m-%dT%H:%M')
    v_data_final =  formata_data(params[:data_final], '+', '%Y-%m-%dT%H:%M')
    @v_data_inicial = v_data_inicial
    @v_data_final = v_data_final
    @cd_empresa = params[:cd_empresa]

    @tot_comps_por_dia = Funcao.where('created_at between ?  and ? and cd_empresa = ? and length(cd_componente) = 8',
                                         v_data_inicial, 
                                         v_data_final, 
                                         "#{params[:cd_empresa]}")
                                  .group_by_day(:created_at)
                                  .count

    linhas_por_dia = []
    Funcao.select('tipo')
          .where('created_at between ? and ? and cd_empresa = ?',
                  v_data_inicial,
                  v_data_final,
                  "#{params[:cd_empresa]}")
          .group(:tipo).each do |reg|
      linhas_por_dia << { 'name': reg.tipo, 'data': Funcao.where('created_at between ? and ? and tipo = ? and cd_empresa = ?',
                                              v_data_inicial,
                                              v_data_final,
                                              reg.tipo, 
                                              "#{params[:cd_empresa]}")
                                      .group_by_day(:created_at).count }
    end
    @tot_linhas_por_dia = linhas_por_dia

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
