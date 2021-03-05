class PainelController < ApplicationController

  layout "application_dashboard"

  def index
    return unless params[:cd_empresa].present?

    report_file = "#{Rails.root}/public/reports/#{params[:cd_empresa]}_linhas_por_modelo_report.rep"
    if File.exist?(report_file)
      @tot_linhas_por_modelo = eval(File.open(report_file).read)
    end

    report_file = "#{Rails.root}/public/reports/#{params[:cd_empresa]}_linhas_por_tipo_report.rep"
    if File.exist?(report_file)
      @tot_linhas_por_tipo = eval(File.open(report_file).read)
    end

    report_file = "#{Rails.root}/public/reports/#{params[:cd_empresa]}_total_linhas_geral_report.rep"
    if File.exist?(report_file)
      @total_linhas = File.open(report_file).read
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

    #linhas_por_dia = []
    #Funcao.select('tipo')
    #      .where('created_at between ? and ? and cd_empresa = ?',
    #              v_data_inicial,
    #              v_data_final,
    #              "#{params[:cd_empresa]}")
    #      .group(:tipo).each do |reg|
    #  linhas_por_dia << { 'name': reg.tipo, 'data': Funcao.where('created_at between ? and ? and tipo = ? and cd_empresa = ?',
    #                                          v_data_inicial,
    #                                          v_data_final,
    #                                          reg.tipo, 
    #                                          "#{params[:cd_empresa]}")
    #                                  .group_by_day(:created_at).count }
    #end
    #@tot_linhas_por_dia = linhas_por_dia

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
