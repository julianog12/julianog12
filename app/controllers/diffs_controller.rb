class DiffsController < ApplicationController

  layout "application_diffs"

  def index
    @diff = Diff.new
    render :show
  end

  def create
    @diff = Diff.new
    if request.post?
      v_encode_salvo = Encoding.default_external
      require 'base64'
      if diffs_params[:before].match(/^(?:[A-Z0-9+\/]{4})*(?:[A-Z0-9+\/]{2}==|[A-Z0-9+\/]{3}=|[A-Z0-9+\/]{4})$/i)
        v_arq_before = Base64.decode64(params[:diff][:before])
        v_arq_before = v_arq_before.gsub /\r/, "\n"

        v_arq_after = Base64.decode64(params[:diff][:after])
        v_arq_after = v_arq_after.gsub /\r/, "\n"

        Encoding.default_external = eval("Encoding::#{v_arq_before.encoding.name.gsub('-','_')}")

        params = ActionController::Parameters.new({
                  diff:{
                    before: v_arq_before,
                    after: v_arq_after
                  }
                })
        permitted = params.require(:diff).permit(:before, :after)
        v_dados = permitted
      else
        v_arq_before = diffs_params[:before]
        v_dados = diffs_params
        Encoding.default_external = eval("Encoding::#{v_arq_before.encoding.name.gsub('-','_')}")
      end

      @diff.attributes = v_dados
    end
    render :show
    Encoding.default_external = v_encode_salvo
  end

  def new
    @diff = Diff.new
  end

  private
  def diffs_params
    params.require(:diff).permit(:before, :after)
  end

end