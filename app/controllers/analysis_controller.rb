class AnalysisController < ApplicationController

  def index
    @analysis ||= Analysis.new
    # if params[:subreddit] && params[:subreddit].blank?
    #   flash[:notice] = 'The subreddit field cannot be empty.'
    # end
    # render 'index'
  end

  def create
    @analysis = Analysis.new analysis_params
    if @analysis.valid?
      # perform search
    else
      flash.now[:alert] = 'Please complete the form below.'
    end
    render :index
  end

  private

  def analysis_params
    params.require(:analysis).permit([:min_upvotes, :subreddit])
  end
end
