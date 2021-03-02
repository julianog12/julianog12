class PainelController < ApplicationController

  def index
    return unless params[:data_inicial].present? && params[:data_final].present?

    v_data_inicial = formata_data(params[:data_inicial], '+', '%Y-%m-%dT%H:%M')
    v_data_final =  formata_data(params[:data_final], '+', '%Y-%m-%dT%H:%M')

    @tot_linhas_por_tipo = Componente.distinct("cd_componente").where('created_at between ?  and ? and cd_empresa = ?',
                                         v_data_inicial, 
                                         v_data_final, 
                                         params[:cd_empresa])
                                  .group_by_day(:created_at)
                                  .count

    #@tot_linhas_por_tipo = []
    #Funcao.select("tipo").where("cd_empresa = '1'").group(:tipo).each do |reg|
    #  Funcao.where('tipo = ?', reg.tipo).select('codigo').each do |regt|
    #    if @tot_linhas_por_tipo.find {|x| x[:name] == reg.tipo}.nil?
    #      @tot_linhas_por_tipo << { name: reg.tipo, data: regt.codigo.count("\n") }
    #    else
	  #      @tot_linhas_por_tipo.find{|h| h[:name] == reg.tipo}[:data] += regt.codigo.count("\n")
    #    end
    #  end
    #end

    @funcoes_comp = []
    Funcao.select('cd_componente')
                          .where("length(cd_componente) = 8 and cd_empresa = '1' and tipo in('entry', 'operation')")
                          .group(:cd_componente)
                          .limit(15)
                          .order('count(id) desc')
                          .count.each do |reg|
      @funcoes_comp << { name: reg[0], data: reg[1] }
    end

    @funcoes = []
    Funcao.select('tipo').where("cd_empresa = '1'").group(:tipo).count.each do |reg|
      @funcoes << { name: reg[0], data: reg[1] }
    end

    p @tot_linhas_por_tipo

    
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
