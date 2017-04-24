# Controller for analysis subreddit search
class AnalysisController < ApplicationController
  def index
    @analysis = Analysis.new
  end

  def create
    @analysis = Analysis.new analysis_params
    if @analysis.valid?
      @analysis.search
      @result = @analysis.analyze
    end
    render :index
  end

  private

  def analysis_params
    params.require(:analysis).permit([:min_upvotes, :subreddit, :time_zone])
  end
end
