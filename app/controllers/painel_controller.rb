class PainelController < ApplicationController

  layout 'application_dashboard'

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

    report_file = "#{Rails.root}/public/reports/#{params[:cd_empresa]}_total_objetos_de_implementacao_modelo_report.rep"
    if File.exist?(report_file)
      @total_objetos_de_impl_modelo = []
      File.readlines(report_file).each do |reg|
        @total_objetos_de_impl_modelo << eval(reg)
      end
    end

    report_file = "#{Rails.root}/public/reports/#{params[:cd_empresa]}_total_objetos_de_implementacao_report.rep"
    if File.exist?(report_file)
      @total_objetos_de_implementacao = eval(File.open(report_file).read)
      @total_linhas_objetos_implementacao = 0
      @total_objetos_de_implementacao.map{|k,v| @total_linhas_objetos_implementacao+= v}
    end

    return unless params[:data_inicial].present? && params[:data_final].present? && params[:cd_empresa].present?

    v_data_inicial = formata_data(params[:data_inicial], '+', '%Y-%m-%dT%H:%M')
    v_data_final =  formata_data(params[:data_final], '+', '%Y-%m-%dT%H:%M')
    @v_data_inicial = v_data_inicial
    @v_data_final = v_data_final
    @cd_empresa = params[:cd_empresa]

    @tot_comps_por_dia = {}
    comps_por_dia = []
    Funcao.where('created_at between ? and ? and cd_empresa = ? and length(cd_componente) in(7,8)',
                                       v_data_inicial,
                                       v_data_final,
                                       params[:cd_empresa].to_s)
                                  .select("cd_componente, to_date(to_char(created_at, 'DD/MM/YYYY'), 'DD/MM/YYYY') dia, count(*) as total")
                                     .group("cd_componente, to_date(to_char(created_at, 'DD/MM/YYYY'), 'DD/MM/YYYY')").each do |reg|
      comps_por_dia << {name: reg.dia.strftime("%d/%m/%Y"), data: reg.total}
    end

    comps_por_dia.each do |it|
      if @tot_comps_por_dia.find {|k,v | k == it[:name]}.nil? 
        @tot_comps_por_dia[it[:name]] = it[:data]
      else
        @tot_comps_por_dia.find{|k,v| k == it[:name]}[1] += 1
      end
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
