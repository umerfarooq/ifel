class QuizzesController < ApplicationController
  uses_tiny_mce :only => [:edit,:update]
  before_filter :redirect_nyu_user
  before_filter :require_admin
#  before_filter :set_new_design_theme, :only => :show
#  before_filter :load_quiz_using_quiz_path

  def index
#    return redirect_to Quiz.published.first
    @quizzes = Quiz.all
  end

  def show
    @quiz = Quiz.find params[:id]
  end

  def edit
    @quiz = Quiz.find params[:id]
  end

  def update
    @quiz = Quiz.find params[:id]
    if @quiz.update_attributes(params[:quiz])
      flash[:notice] = "Quiz updated successfully."
      return redirect_to quiz_url
#      return redirect_to quiz_url(@quiz.path)
    else
      render :action => 'edit'
    end
  end

  def publish
    quiz = Quiz.find params[:id]
    if quiz.publish
      flash[:notice] = "Quiz successfully published"
    else
      flash[:notice] = "Quiz is not publishable"
    end
    redirect_to quiz
  end

  def activate
    quiz = Quiz.find params[:id]
    if quiz.activate
      flash[:notice] = "Quiz successfully activated"
    else
      flash[:notice] = "Quiz is not activatable"
    end
    redirect_to quiz
  end

  def inactivate
    quiz = Quiz.find params[:id]
    if quiz.inactivate
      flash[:notice] = "Quiz successfully inactivated"
    else
      flash[:notice] = "Quiz is not inactivatable"
    end
    redirect_to quiz
  end

  private
  def load_quiz_using_quiz_path
    @quiz = Quiz.find_by_path(params[:id])
    if @quiz.blank?
      flash[:notice] = "We're sorry, but we could not locate the quiz you requested."
      return redirect_to root_url
    end
  end
end
