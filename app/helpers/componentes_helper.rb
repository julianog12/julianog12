module ComponentesHelper

    def sele_nome(emp, tipo, nome, dt_alteracao)
        v_empresa = case emp
            when "1" then "Coamo Desenv"
            when "2" then "Coamo Prod"
            when "3" then "Credi Desenv"
            when "4" then "Credi Prod"
        end
        "<h3>#{v_empresa} - #{tipo.upcase} #{nome}  <b style='font-size: 10px'>Atualizado em: #{dt_alteracao.strftime("%d/%m/%Y %H:%M:%S")}</b></h3>".html_safe
    end

    def monta_funcao(componente, empresa, nome_funcao, codigo_funcao, dt_alteracao, contador)
        codigo_funcao = codigo_funcao.encode("utf-8")
        vLinha  = %{<button type="button" class="btn btn-link" data-toggle="modal" data-target=".bd-local-#{contador}-modal-xl">#{nome_funcao}</button> <b style='font-size: 10px'>Atualizado em: #{dt_alteracao.strftime("%d/%m/%Y %H:%M:%S")}</b>}
        %{  </br>
            #{vLinha}
            <div class="modal fade bd-local-#{contador}-modal-xl" tabindex="-1" role="dialog" aria-labelledby="t#{contador}" style="display: none;" aria-hidden="true">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title h4" id="t#{contador}">#{nome_funcao}</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">×</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <pre style="font-family: Courier New;font-size: 12px;max-height: 700px;">#{codigo_funcao}</pre>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
                        </div>

                    </div>
                </div>
            </div>
        }.html_safe
    end


    def separa_activate2(contador, nome, empresa, linha)
        if linha.match(/activate\s.*\".*\"/i) or linha.match(/activate\/stateless\s.*\".*\"/i)
            begin
                v1      = linha.index(".") 
                v4      = v1
                v1      += 1

                v2      = linha.index("\(")
                v5      = v2
                v2      -= 1
                v3      = linha[v1..v2]
                v3      = v3.gsub(" ", "")

                vLinha  = "#{linha[0..v4]}"+ %{<button type="button" class="btn btn-link" data-toggle="modal" data-target=".bd-#{contador}-modal-xl">#{v3}</button>}+"#{linha[v5..300]}"
                vLinha  = vLinha.gsub("\n", "")

                v1      = linha.index(".") +1
                v2      = linha.index("\(")-1
                v3      = linha[v1..v2].gsub(" ", "").downcase

                v1      = linha.index("\"")+1
                v2      = linha[v1..300]
                v5      = v2.index("\.")-1

                v4      = linha[v1,v5]
                v4      = v4.downcase

                codigo  = ""
                begin
                    codigo = Funcao.where("cd_componente = ? and nm_funcao = ? and cd_empresa = ?", v4, v3, empresa).first.codigo
                    codigo = codigo.gsub("\n", "</br>")
                    codigo = codigo.gsub("\t", "&emsp;")
		    codigo = codigo.encode('utf-8')
                rescue
                    codigo = ""
                end

                if !codigo.empty?
                  %{                    
                    #{vLinha}
                    
                    <div class="modal fade bd-#{contador}-modal-xl" tabindex="-1" role="dialog" aria-labelledby="t#{contador}" style="display: none;" aria-hidden="true">
                        <div class="modal-dialog modal-xl">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title h4" id="t#{contador}">#{v3}</h5>
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">×</span>
                                    </button>
                                </div>
                                <div class="modal-body">
                                    <pre style="font-family: Courier New;font-size: 12px;max-height: 700px;">#{codigo}</pre>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
                                </div>

                            </div>
                        </div>
                    </div>
                    }
                else
                    linha
                end               

            rescue
                linha
            end
        else
            linha
        end
    end

end



