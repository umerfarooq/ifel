class CommentsController < ApplicationController

  load_and_authorize_resource :message
  load_and_authorize_resource :comment, :through => :message

#  before_filter :require_user # CANCAN

  before_filter :require_payment
  before_filter { |c| c.active_tab=:community }

  def index
    @comments = @message.comments.appropriate.for_user(@current_user).paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
    @message.reviewed_by!(@current_user)
    @comment = Comment.new
  end

  def new
  end


  def create
    Comment.create(params, current_user, message)
#    @comment.body.gsub!("\r\n","<br />")
#    @comment.user = current_user
#    if @comment.save
#      @comment.send_later(:deliver_reply_to_message_email)
#      flash[:success] = "Thank you, your response has been posted."
#      redirect_to message_comments_url(@message)
#    else
#      render :action => 'index'
#    end
    redirect_to :controller=>"messages", :action=>""
  end

  def show
    redirect_to message_comments_path(:message_id => params[:message_id])
  end

  def edit
    @comment.body.gsub!("<br />", "\r\n")    
  end

  def update
    params[:comment][:body].gsub!("\r\n","<br />")
#    @comment = @current_user.comments.find params[:id] # CANCAN
#    return render :json => [params, @comment, @message]
    if @comment.update_attributes(params[:comment])
      flash[:notice] = "Comment updated successfully."
      redirect_to message_comments_path(@comment.commentable)
    else
      render :action => 'edit'
    end
  end

  def report_abuse
    if @comment.unanswered_inappropriate_by?(@current_user)
      flash[:notice] = "Thank you! but your request for this message is already with us and we will inform you shortly."
    else
      if @comment.mark_inappropriate_by(@current_user)
        flash[:notice] = "Thank you! we have recorded your request and you will be informed shortly."
      else
        flash[:error] = "Thank you! but your request could not be entertained, please try later."
      end
    end
    redirect_to message_comments_url(@comment.commentable)
  end

  def thumbsup
    if @comment.rated_by?(@current_user)
      flash[:error] = "Thank you! But you have already rated this comment."
    else
      if @comment.rate_positively_by(@current_user, true)
        flash[:notice] = "Thank you! Your rating for this comment has been updated."
      else
        flash[:error] = "Thank you! But your message rating could not be saved, please try later."
      end
    end
    redirect_to message_comments_url(@comment.commentable)
  end

  def thumbsdown
#    @comment = Comment.find params[:id] # CANCAN
    if @comment.rated_by?(@current_user)
      flash[:error] = "Thank you! But you have already rated this comment."
    else
      if @comment.rate_positively_by(@current_user, false)
        flash[:notice] = "Thank you! Your rating for this comment has been updated."
      else
        flash[:error] = "Thank you! But your message rating could not be saved, please try later."
      end
    end
    redirect_to message_comments_url(@comment.commentable)
  end

end
