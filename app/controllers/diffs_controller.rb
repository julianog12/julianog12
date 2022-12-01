class DiffsController < ApplicationController

  layout "application_diffs"

  def index
    @diff = Diff.new
    render :show
  end

  def create
    @diff = Diff.new
    if request.post?
      require 'base64'
      if (diffs_params[:before].match(/^(?:[A-Z0-9+\/]{4})*(?:[A-Z0-9+\/]{2}==|[A-Z0-9+\/]{3}=|[A-Z0-9+\/]{4})$/i))
        diffs_params[:before] = Base64.decode64(diffs_params[:before])
        diffs_params[:after]  = Base64.decode64(diffs_params[:after])
      end
      @diff.attributes = diffs_params
    end
    render :show
  end

  def new
    @diff = Diff.new
  end

  private
  def diffs_params
    params.require(:diff).permit(:before, :after)
  end

end
