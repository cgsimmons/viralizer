# Controller for analysis subreddit search
class AnalysisController < ApplicationController
  def index
    @analysis = Analysis.new
  end

  def create
    @analysis ||= Analysis.new analysis_params
    @result = analyze
    render :index
  end

  private

  def analysis_params
    params.require(:analysis).permit([:min_upvotes, :subreddit, :time_zone])
  end

  def analyze
    return search if @analysis.valid?
    flash.now[:alert] = 'Please correct your errors.'
    nil
  end

  def search
    return @analysis.analyze if @analysis.search
    if @analysis.errors.messages.empty?
      flash.now[:alert] = 'Unable to connect to Reddit. ' \
                          'Try again in a few minutes'
    else
      flash.now[:alert] = 'Please correct your errors.'
    end
    nil
  end
end
