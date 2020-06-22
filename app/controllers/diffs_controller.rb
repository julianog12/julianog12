class DiffsController < ApplicationController

  layout "application_diffs"

  def index
    @diff = Diff.new
    render :show
  end

  def create
    @diff = Diff.new
    if request.post?
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
