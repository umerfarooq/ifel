class QuizRepliesController < ApplicationController
  #  before_filter :require_no_user
  #  before_filter { |c| c.active_tab = :home }
  before_filter :set_new_design_theme

  def new
    #    return render :json => params
    quiz = Quiz.find_by_path(params[:quiz_path])
    @back_url ||= request.env['HTTP_REFERER'] || root_url
    if(quiz.blank? || !quiz.published?)
      flash[:error] = "Sorry, your request cannot be entertained at this point."
      return redirect_to @back_url
    end
    session[:quiz_path] = params[:quiz_path]
    @quiz_reply = QuizReply.new_with_quiz(quiz)
    #    return render :json => [@quiz_reply, @quiz_reply.answers]
  end

  def create
    @back_url = params[:back_url]
    @quiz_reply = QuizReply.new(params[:quiz_reply])
    unless params[:quiz_reply][:answers_attributes].blank?
      @quiz_reply.quiz = Quiz.find_by_path(session[:quiz_path])
      if (params[:quiz_reply][:answers_attributes].length == @quiz_reply.quiz.questions.published.length)
        QuizReply.associate_questions_to_answers(@quiz_reply)
        if @quiz_reply.save
          @quiz_reply.send_later(:deliver_quiz_reply_email)
          session[:quiz_path] = nil
          return redirect_to thanks_quiz_reply_path(@quiz_reply, :back_url => @back_url)
        else
          flash[:error] = "Sorry, your request cannot be entertained at this point."
        end
      else
        flash[:error] = "You must answer all the Questions, to go with this Quiz."
      end
    else
      flash[:error] = "You must answer all the Questions, to go with this Quiz."
    end
    return redirect_to '/'.concat(params[:current_quiz_path])
  end

  def thanks
    @quiz_reply = QuizReply.find(params[:id])
    @back_url = params[:back_url]
  end

end
