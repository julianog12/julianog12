class PainelController < ApplicationController
  respond_to :json, :html, :js

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

    @cd_empresa = params[:cd_empresa]

    return unless params[:data_inicial].present? && params[:data_final].present? && params[:cd_empresa].present?

    v_data_inicial = formata_data(params[:data_inicial], '', '%Y-%m-%dT%H:%M')
    v_data_final =  formata_data(params[:data_final], '', '%Y-%m-%dT%H:%M')
    @v_data_inicial = v_data_inicial
    @v_data_final = v_data_final

    @tot_comps_por_dia = {}
    comps_por_dia = []
    Funcao.where('created_at between ? and ? and cd_empresa = ? and length(cd_componente) in(7,8)',
                                       v_data_inicial,
                                       v_data_final,
                                       params[:cd_empresa].to_s)
                                  .select("cd_componente, to_date(to_char(created_at, 'DD/MM/YYYY'), 'DD/MM/YYYY') dia, count(*) as total")
                                  .order("dia asc")
                                  .group("cd_componente, to_date(to_char(created_at, 'DD/MM/YYYY'), 'DD/MM/YYYY')").each do |reg|
      dia_semana = I18n.l(reg.dia, format: "%a")
      if comps_por_dia.find{|x| x[:name]==reg.dia.strftime("#{dia_semana} %d/%m/%Y")}.nil?
        comps_por_dia << {name: reg.dia.strftime("#{dia_semana} %d/%m/%Y"), data: 1}
      else
        comps_por_dia.find{|x| x[:name]==reg.dia.strftime("#{dia_semana} %d/%m/%Y")}[:data]+= 1
      end
    end

    comps_por_dia.each do |it|
      @tot_comps_por_dia[it[:name]] = it[:data]
    end
  end

  def show
    @model_componentes = Funcao.where("cd_empresa = ? and nm_modelo = ? and length(cd_componente) in(7,8) and substring(cd_componente,1,4) not in ('acon', 'acre')",
                               params[:empresa].to_s,
                               params[:id])
                               .select("cd_componente, sum(nr_linhas) as nr_linhas")
                               .group("cd_componente")
                               .order("2 desc")
    respond_with(@model_componentes)
  end

  def formata_data(data, sinal, formato)
    v1 = data[0..3]
    v2 = data[5..6]
    v3 = data[8..9]
  
    v4 = data[11..12].to_i
    if sinal == '-'
      v4 -= 3
    elsif sinal == '+'
      v4 += 3
    end
    v5 = data[14..15]
    v6 = data[17..18]

    #date_and_time = '%d-%m-%Y %H:%M:%S'
    data_hora = DateTime.parse("#{v1}-#{v2}-#{v3} #{v4.to_s}:#{v5}:#{v6}", formato)
    data_hora.strftime(formato)
  end

end
