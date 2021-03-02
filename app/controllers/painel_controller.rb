class PainelController < ApplicationController

  def index
    @tot_linhas_por_tipo = []
    Funcao.select("tipo").where("cd_empresa = '1'").group(:tipo).each do |reg|
      Funcao.where('tipo = ?', reg.tipo).select('codigo').each do |regt|
        if @tot_linhas_por_tipo.find {|x| x[:name] == reg.tipo}.nil?
          @tot_linhas_por_tipo << { name: reg.tipo, data: regt.codigo.count("\n") }
        else
	        @tot_linhas_por_tipo.find{|h| h[:name] == reg.tipo}[:data] += regt.codigo.count("\n")
        end
      end
    end

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

    respond_with(@funcoes.to_json, @funcoes_comp.to_json, @tot_linhas_por_tipo.to_json)
  end
end
