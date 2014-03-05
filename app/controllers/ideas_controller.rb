class IdeasController < ApplicationController
  before_filter :authenticate_user!
  def index
    @idea = Idea.new
    @ideas = Idea.all
  end

  def new
    @idea = Idea.new
  end

  def create
    @idea = current_user.ideas.create(idea_params)
    respond_with @idea
  end

  private

  def idea_params
    params.require(:idea)
          .permit(:content, :user_id)
  end
end
