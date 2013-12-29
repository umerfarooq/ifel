class QuestionsController < ApplicationController
  before_filter :require_admin

  def show
    @question = Question.find params[:id]
  end

  def new
    @quiz = Quiz.find params[:quiz_id]
    @question = @quiz.questions.build
#    @question = Question.new
  end

  def create
    @quiz = Quiz.find params[:quiz_id]
#    @question = Question.new(params[:question])
    @question = @quiz.questions.build(params[:question])
#    return render :json => [params, @question]
    if @question.save
      flash[:notice] = "Question successfully added."
      return redirect_to @quiz
    else
      render :action => 'new'
    end
  end

  def edit
    @quiz = Quiz.find params[:quiz_id]
    @question = Question.find params[:id]
  end

  def update
    @quiz = Quiz.find params[:quiz_id]
    @question = Question.find params[:id]
    if @question.update_attributes(params[:question])
      flash[:notice] = "Question updated successfully."
      return redirect_to @quiz
    else
      render :action => 'edit'
    end
  end

  def publish
    question = Question.find params[:id]
    if question.publish
      flash[:notice] = "Question successfully published"
    else
      flash[:notice] = "Question is not publishable"
    end
    redirect_to question.quiz
  end

  def activate
    question = Question.find params[:id]
    if question.activate
      flash[:notice] = "Question successfully activated"
    else
      flash[:notice] = "Question is not activatable"
    end
    redirect_to question.quiz
  end

  def inactivate
    question = Question.find params[:id]
    if question.inactivate
      flash[:notice] = "Question successfully inactivated"
    else
      flash[:notice] = "Question is not inactivatable"
    end
    redirect_to question.quiz
  end

  def move_up
    question = Question.find params[:id]
    if question.move_up
      flash[:notice] = "Question successfully moved up"
    else
      flash[:notice] = "Question could not be moved up"
    end
    redirect_to question.quiz
  end

  def move_down
    question = Question.find params[:id]
    if question.move_down
      flash[:notice] = "Question successfully moved down"
    else
      flash[:notice] = "Question could not be moved down"
    end
    redirect_to question.quiz
  end

end
