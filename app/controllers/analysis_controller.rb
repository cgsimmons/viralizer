# Controller for analysis subreddit search
class AnalysisController < ApplicationController
  def index
    @analysis ||= Analysis.new
  end

  def create
    @analysis = Analysis.new analysis_params
    if @analysis.valid?
      @analysis.search
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
