class DiffsController < ApplicationController

  layout "application_diffs"

  def index
    @diff = Diff.new
    render :show
  end

  def create
    @diff = Diff.new
    if request.post?
       vEncodeSalvo = Encoding.default_external
       require 'base64'
       if (diffs_params[:before].match(/^(?:[A-Z0-9+\/]{4})*(?:[A-Z0-9+\/]{2}==|[A-Z0-9+\/]{3}=|[A-Z0-9+\/]{4})$/i))
         vArqBefore = Base64.decode64(params[:diff][:before])
         vArqBefore = vArqBefore.gsub /\r/, "\n"

         vArqAfter = Base64.decode64(params[:diff][:after])
         vArqAfter = vArqAfter.gsub /\r/, "\n"

         Encoding.default_external = eval("Encoding::#{vArqBefore.encoding.name.gsub('-','_')}")

         params = ActionController::Parameters.new({
                   diff: {
                      before: vArqBefore,
                      after: vArqAfter
                        }
                  })
         permitted = params.require(:diff).permit(:before, :after)
         vDados = permitted
       else
         vArqBefore = diffs_params[:before]
         vDados = diffs_params
         Encoding.default_external = eval("Encoding::#{vArqBefore.encoding.name.gsub('-','_')}")

       end

       @diff.attributes = vDados
    end
    render :show
    Encoding.default_external = vEncodeSalvo
  end


  def new
    @diff = Diff.new
  end

  private
  def diffs_params
    params.require(:diff).permit(:before, :after)
  end

end
