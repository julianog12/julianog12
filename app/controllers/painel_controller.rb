class PainelController < ApplicationController

  def index
    return unless params[:data_inicial].present? && params[:data_final].present?

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

    puts "@tot_comps_por_dia"
    puts @tot_comps_por_dia
    puts @tot_comps_por_dia.class
    #@tot_linhas_por_dia = []
    #Funcao.select('tipo').where('cd_empresa = ?', "#{params[:cd_empresa]}").group(:tipo).each do |reg|
    #  Funcao.where('tipo = ? and cd_empresa = ?', reg.tipo, "#{params[:cd_empresa]}").select('codigo').each do |regt|
    #    if @tot_linhas_por_dia.find {|x| x[:name] == reg.tipo}.nil?
    #      @tot_linhas_por_dia << { name: reg.tipo, data: regt.codigo.count("\n") }
    #    else
	  #      @tot_linhas_por_dia.find{|h| h[:name] == reg.tipo}[:data] += regt.codigo.count("\n")
    #    end
    # end
    #end
    #p @tot_linhas_por_dia


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
    #@tot_linhas_por_dia = Hash[linhas_por_dia.each_slice(2).to_a]
    @tot_linhas_por_dia = linhas_por_dia
    puts "@tot_linhas_por_dia"
    puts @tot_linhas_por_dia
    puts @tot_linhas_por_dia.class
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
