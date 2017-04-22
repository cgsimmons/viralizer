# Controller for analysis subreddit search
class AnalysisController < ApplicationController
  def index
    @analysis ||= Analysis.new
  end

  def create
    @analysis = Analysis.new analysis_params
    @analysis.search if @analysis.valid?
    render :index
  end

  private

  def analysis_params
    params.require(:analysis).permit([:min_upvotes, :subreddit])
  end
end
