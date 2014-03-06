class IdeasController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html
  respond_to :json

  def index
    @idea = Idea.new
    @ideas = current_account.ideas
  end

  def new
    @idea = Idea.new
  end

  def create
    @idea = current_user.ideas.create(idea_params)
    respond_with @idea, location: ideas_path
  end

  private

  def idea_params
    params.require(:idea)
          .permit(:content, :user_id)
  end
end
