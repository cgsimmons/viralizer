class AnalysisController < ApplicationController

  def index
    if params[:subreddit] && params[:subreddit].blank?
      flash[:notice] = 'The subreddit field cannot be empty.'
    end
    render 'index'
  end
end
