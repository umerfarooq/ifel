class MessagesController < ApplicationController
  #load_and_authorize_resource
  uses_tiny_mce :only => [:show_message_detail_page, :index,:create_comment, :community_profile,:topic_search, :search, :edit_post_question_content]
  before_filter :require_user
  before_filter :require_payment
  before_filter { |c| c.active_tab=:community }
  before_filter :set_new_design_theme, :except => :edit_post_question_content
  #  :only => [:indexnew]
  before_filter :require_payment
  before_filter { |c| c.active_tab=:community }
  before_filter(:only => :edit_post_question_content) { |c| c.active_tab=:content_tab }
  before_filter :load_community_experts, :only => [:index, :topic_search, :search, :create]

  
  def index
    @post_quest = false
    @is_msg_partial = false
    @is_user_question_list = false
    if !params[:post_quest].blank?
      if params[:post_quest] == "true"
        @post_quest = true
      end
    end
    
    if !params[:is_msg_partial].blank?
      @is_msg_partial = params[:is_msg_partial]
      @message_for_detail = Message.find(params[:message_for_detail].to_i)
    end
    @feedwall_messages = Message.recent_messages()

    if !params[:is_user_question_list].blank?
      @is_user_question_list = true
      @user_unread_comments = Comment.get_user_messages_unread_comments(current_user)
    end

    @followd_message_result = SubjectFollowing.find_all_by_user_id_and_subject_type(current_user.id, "Message")
    @topics = SubjectFollowing.get_topics_followed_by_user(current_user)
    
    @message_main = MarketingTextMessage.find_by_page_and_location("community", "main")
    if params[:user_id]
      if params[:user_id].to_s == @current_user.id.to_s
        @heading = "My Messages"
        @messages = @current_user.messages.appropriate.date_wise.paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
      else
        user = User.find(params[:user_id])
        @heading = "Messages from #{user.screen_name.capitalize}"
        @messages = user.messages.appropriate.not_for_admin.date_wise.paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
      end
    else
      @heading = "Recent Messages"
      #      @messages = Message.appropriate.not_for_admin.date_wise.paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
      @messages = Message.appropriate.for_user(@current_user).date_wise.paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
      #      @messages = Message.find_all_by_is_appropriate_and_is_admin_only(true, false, :order => 'created_at DESC').paginate(:page=>params[:page], :per_page => per_page)
    end
  end

  def popular
    @message_main = MarketingTextMessage.find_by_page_and_location("community", "main")
    @heading = "Popular Topics"
    @messages = Message.appropriate.not_for_admin.view_count_wise.paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
    #    @messages = Message.find_all_by_is_appropriate(true, :order => 'view_count DESC').paginate(:page=>params[:page], :per_page => per_page)
    render :action => "index"
  end

  def for_staff
    @message_main = MarketingTextMessage.find_by_page_and_location("community", "main")
    @heading = "Private Messages for Wicked Start Staff"
    @messages = Message.for_admin.date_wise.paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
    render :action => "index"
  end

  def new
    #@message = Message.new
  end

  def create
    @feedwall_messages = Message.recent_messages
    Message.create_message(params,current_user)
    return render :partial => "messages/default_search", :locals=>{:messages => Message.recent_messages, :topic => nil }
  end

  def search
    @feedwall_messages = Message.search_messages(params, request)
    return render :action => :index    
  end

  def create_comment
    comment =  Comment.create_comment(params, current_user)
    unless comment.blank?
      #Modified to send a single email when some answer is posted on the Question
      comment.deliver_comment_email
      
#      comment.deliver_comment_email_in_model()
#      comment.message.deliver_comment_on_message_email_in_model(comment)
    end
    if request.xhr?
      render :partial => "message_detail_page", :locals => {:message => Message.find(params[:message])}
    end
  end

  def show_message_detail_page    
    if request.xhr?
      render :partial => "message_detail_page", :locals => {:message => Message.find(params[:msg])}
    end
  end

  def topic_search
    @feedwall_messages = Topic.find(params[:topic]).messages
    @topic_id = params[:topic]
    return render :action => :index 
  end
  
  def update_message_topics
    Message.find(params[:msg]).update_topic(params)
    if request.xhr?
      render :partial => "message_topics", :locals => {:message => Message.find(params[:msg])}
    end
  end

  def update_message_body
    message = Message.find(params[:message])
    #    begin
    if message.update_attribute(:body, params[:body])
      message.deliver_edit_message_email_to_followers()
    end
   
    #        return render :text => 'success'
    #      end
    #    rescue Exception => e
    #      return render :text => e.message
    #    end
    if request.xhr?
      if params[:content] == 'community_profile'
        render :partial => "message_content", :locals => {:message => Message.find(params[:message])}
      else
        render :partial => "message_body", :locals => {:message => Message.find(params[:message])}
      end
    end
  end

  def community_profile
    @marketing_text_message = MarketingTextMessage.find_by_page_and_location("messages", "post_question")
    @message = Message.recent_message_or_comment_of_user(current_user)
    #    @comment = Comment.recent_comment_of_message(@message.first)
    @comment = @message.comments.datewise.only 1 unless @message.blank?
    #redirect_to "messages/community_profile"
    #return render :text => @comment
    #@comments = @message.comments.appropriate.for_user(@current_user).paginate(:page => params[:page], :per_page => PAGINATION_MESSAGES_COUNT)
    #return render :xml => @message
    #@comment = Message.recent_comment_of_message_user(current_user)
    #     if request.xhr?
    #       render :partial => "community_profile", :locals => {:messages => @message, :comment => @comment}
    #     end
  end

  def topic_categories
    @sections = current_user.project.sections
  end


  def display_more_questions
    offset = params[:offset].to_i
    feedwall_messages = Message.recent_messages(offset)

    if request.xhr?
      return render :partial => 'community_questions', :locals => {:messages => feedwall_messages, :topic => @topic_id, :display_more_check => 10}
      #    render :partial => , :display_more_check => 10 }
    end
  end
  
  def unfollow_question
    message = Message.find(params[:id].to_i)
    current_user.stop_following(message)
    if params[:content] == "detail_page"
      render :partial => "message_detail_page", :locals => {:message => Message.find(params[:id])}
    else
      render :partial => "message_details", :locals => {:msg => Message.find(params[:id]), :topic=>@topic_id}
    end
    #    SubjectFollowing.delete(params[:id])
    #    if params[:subject] == "Topic"
    #      #to do ijn next phase
    #    else if params[:subject] == "Message"
    #        if params[:content] == "detail_page"
    #          render :partial => "message_detail_page", :locals => {:message => Message.find(params[:msg_id])}
    #        else
    #          render :partial => "message_details", :locals => { :msg => Message.find(params[:msg_id]), :topic=>@topic_id }
    #        end
    #      end
    #    end
  end

  #Likings used by message in order to vote
  #like used by comment in order to mark it helpful and not helpful

  def question_helpful
    #    if Liking.find_by_likeable_type_and_likeable_id_and_user_id("Comment", params[:id], current_user.id).blank?

    comment = Comment.find(params[:id])
    unless comment.liking_by_user?(@current_user)
      liking = Liking.new(:liking => 1)
      liking.user = current_user
      comment.add_liking(liking)
    else
      Liking.find_by_likeable_type_and_likeable_id_and_user_id("Comment", params[:id], current_user.id).update_attribute(:liking, true)
    end
    if request.xhr?
      render :partial => "comment_detail", :locals => {:comment => Comment.find(params[:id])}
    end
  end

  def vote_message
    message = Message.find(params[:msg])
    liking = Liking.new(:liking => 1)
    liking.user = current_user
    message.add_liking(liking)
    if request.xhr?
      render :partial => "message_details", :locals => {:msg => Message.find(params[:msg]), :topic=>@topic_id}
    end
  end

  
  
  def question_nothelpful
    Liking.find_by_likeable_type_and_likeable_id_and_user_id("Comment", params[:id].to_i, current_user.id).update_attribute(:liking, false)

    #     comment = Comment.find(params[:id])
    #     liking = Liking.new(:liking => 0)
    #     liking.user = current_user
    #     comment.add_liking(liking)
    if request.xhr?
      render :partial => "comment_detail", :locals => {:comment => Comment.find(params[:id])}
    end
  end

  def comment_appropriate
    Inappropriate.find_by_appropriable_type_and_appropriable_id_and_user_id(params[:content], params[:id], @current_user.id).update_attribute(:is_answered, true)
    if params[:content] == "comment"
      if request.xhr?
        render :partial => "comment_detail", :locals => {:comment => Comment.find(params[:id])}
      end
    else
      if request.xhr?
        render :partial => "question_inappropriate_partial", :locals => {:message => Message.find(params[:id])}
      end
    end
  end

  def comment_inappropriate
    if Inappropriate.find_by_appropriable_type_and_appropriable_id_and_user_id(params[:content], params[:id], @current_user.id).blank?
      inappropriate = Inappropriate.new(:is_answered => 0)
      if params[:content] == 'comment'
        inappropriate.appropriable = Comment.find(params[:id])
      else
        inappropriate.appropriable = Message.find(params[:id])
      end
      inappropriate.user = current_user
      inappropriate.save
    else
      Inappropriate.find_by_appropriable_type_and_appropriable_id_and_user_id(params[:content], params[:id], @current_user.id).update_attribute(:is_answered, false)
    end
    if params[:content] == "comment"
      if request.xhr?
        render :partial => "comment_detail", :locals => {:comment => Comment.find(params[:id])}
      end
    else
      if request.xhr?
        render :partial => "question_inappropriate_partial", :locals => {:message => Message.find(params[:id])}
      end
    end
  end

  def add_topic

  end
  def follow_question
    message = Message.find(params[:id].to_i)
    current_user.follow(message)
    message.deliver_following_a_question_email(current_user)
    if params[:content] == "detail_page"
      render :partial => "message_detail_page", :locals => {:message => Message.find(params[:id])}
    else
      render :partial => "message_details", :locals => {:msg => Message.find(params[:id]), :topic=>@topic_id}
    end

    #    @new_subject_following = SubjectFollowing.new
    #    @new_subject_following.user = current_user
    #
    #    if params[:subject] == "Topic"
    #      @new_subject_following.subject = Topic.find(params[:id])
    #      if @new_subject_following.save
    #      end
    #    else if params[:subject] == "Message"
    #        message = Message.find(params[:id])
    #        @new_subject_following.subject = message
    #        if @new_subject_following.save
    #          message.deliver_following_a_question_email(current_user)
    #          if params[:content] == "detail_page"
    #            render :partial => "message_detail_page", :locals => {:message => Message.find(params[:id])}
    #          else
    #          render :partial => "message_details", :locals => {:msg => Message.find(params[:id]), :topic=>@topic_id}
    #          end
    #        end
    #      end
    #    end
  end


  
  def edit
    #    @message = @current_user.messages.find params[:id] # CANCAN
    @message.body.gsub!("<br />", "\r\n")
  end

  def update
    params[:message][:body].gsub!("\r\n","<br />")
    #    @message = @current_user.messages.find params[:id] # CANCAN
    if @message.update_attributes(params[:message])
      flash[:notice] = "Message updated successfully."
      redirect_to message_comments_path(@message)
    else
      render :action => 'edit'
    end
  end

  def show
    #    @message = Message.find params[:id] # CANCAN
    redirect_to message_comments_url(@message)
  end

  def report_abuse
    #    @message = Message.find params[:id] # CANCAN
    if @message.unanswered_inappropriate_by?(@current_user)
      flash[:notice] = "Thank you! but your request for this message is already with us and we will inform you shortly."
    else
      if @message.mark_inappropriate_by(@current_user)
        flash[:notice] = "Thank you! we have recorded your request and you will be informed shortly."
      else
        flash[:error] = "Thank you! but your request could not be entertained, please try later."
      end
    end
    redirect_to message_comments_url(@message)
  end

  def load_questions
    return render :text => Message.load_questions(params[:term])
  end
  
  def edit_post_question_content
    @marketing_text_message = MarketingTextMessage.find params[:id]
  end
  
  def update_post_question_content
    @marketing_text_message = MarketingTextMessage.find params[:id]
    if @marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:notice] = "Post Question Content updated successfully."
      redirect_to community_tab_admins_path
    else
      render :action => 'edit_post_question_content'
    end
  end

  private
  def load_community_experts
    @community_experts = User.community_experts_with_comments.only 9
  end

end
