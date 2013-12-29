module MessagesHelper

  
  def image_submit_tag(source, options = {})
    options.stringify_keys!
    if confirm = options.delete("confirm")
      add_confirm_to_attributes!(options, confirm)
    end
    tag :input, { "type" => "image", "src" => path_to_image(source) }.update(options.stringify_keys)
  end

  def message_details(msg)
    return "#{msg.created_at.strftime("%l%p on %A, %B %d, %Y")}- #{message_answers_count(msg)} Answer(s) -#{message_following_count(msg)} Following(s) - #{is_message_followed(msg.id, false)}"
  end

  def message_detail(msg)
    return "#{ws_date_format_with_time_and_meridiem_first_with_day(msg.created_at)} - #{message_answers_count(msg)} Answer(s) -#{message_following_count(msg)} Following(s)"
  end
  
  def message_details_for_detail_page(msg)
    return "#{msg.created_at.strftime("%l%p on %A, %B %d, %Y")}- #{is_message_followed(msg.id, true)}"
  end



  def helper_check_msg_presence_before(comments)
    messages = Hash.new
    comments.each do |comment|
    msg = comment.commentable
    if !messages.has_key?(msg.id)
      messages[msg.id] = msg
    end
  end
  return messages
  end

  def appropriate_user_for_message?(msg,current_user)
    if msg.user_id.equal?(current_user.id)
      #      User.find(msg.user_id).equal?(current_user)
      return true
    else
      return false
    end
  end

  def get_marketing_message_text()
    return MarketingTextMessage.find_by_page("messages")
  end

  def get_all_topics()
#    return Topic.all.map(&:token_inputs)
    return Topic.find_all_by_state_id_and_is_orphan(3, false).map(&:token_inputs)
  end

  def get_topics_of_msg(message_id)
    return Message.find(message_id).topics.map(&:token_inputs)
  end
   
  def get_all_messages()
    Message.all(:select => "body").map { |x| x.body }.to_json
  end
  
  def get_recent_message_of_user(user)
    return Message.recent_message_of_user(user)
  end

  def get_recent_comment_of_user(user)
    return Comment.any_recent_comment_of_user(user)
  end

  def get_recent_messages()
    return Message.recent_messages();
  end

  def message_following_list()
    return SubjectFollowing.find_all_by_user_id_and_subject_type(@current_user.id,"Message")
  end

  def topic_following_list()
    return SubjectFollowing.find_all_by_user_id_and_subject_type(@current_user.id, "Topic")
  end

  def message_following_count(msg)
    return SubjectFollowing.get_messages_followed_count(msg)
  end
  def message_answers_count(msg)
    return Comment.get_comment_count_on_messages(msg, @current_user)
  end
  def recent_comment_of_message(msg)
    return Comment.recent_comment_of_message(msg)
  end
  def get_user(user_id)
    return User.find(user_id)
  end
  def get_user_name(message_id)
    message = Message.find(message_id)
    return message.user.name
  end
  def has_comment?(msg)
    if Comment.recent_comment_of_message(msg).blank?
      return false
    else
      return true
    end
  end
  
  def get_followed_topic_name(subject_id)
    topic_name = Topic.find(subject_id)
    return topic_name.name
  end

  def is_message_followed_for_image(msg_id)
    flag = false
    subject_id = 0
    followd_message_result = message_following_list()
    followd_message_result.each do |t|
      if
        t.subject_id.equal?(msg_id)
        flag = true
        subject_id = t.id
        break
      end
    end
    if flag == true
      return  "#{link_to image_tag('un-follow-question-btn.png'), 'JavaScript:void(0);', :onclick=>"unfollow_message_detail_page(#{subject_id},#{msg_id})"}"
    else
      return  "#{link_to image_tag('theme/follow-question-btn.png'),'JavaScript:void(0);', :onclick=>"follow_message_detail_page(#{msg_id})"}"
    end
  end
  
  def is_message_followed(msg_id, detail_page)
    flag = false
    subject_id = 0
    followd_message_result = message_following_list()
    followd_message_result.each do |t|
      if
        t.subject_id.equal?(msg_id)
        flag = true
        subject_id = t.id
        break
      end
    end
    if flag == true
      if @current_user.following? msg
        if detail_page
          return "#{link_to 'unfollow', 'JavaScript:void(0);', :onclick=>"unfollow_message_detail_page(#{subject_id},#{msg_id})"}"
        else
          return "#{link_to 'unfollow', 'JavaScript:void(0);', :onclick=>"unfollow_message(#{subject_id},#{msg_id})"}"
        end
      else
        if detail_page
          return "#{link_to 'follow', 'JavaScript:void(0);', :onclick=>"follow_message_detail(#{msg_id})"}"
        end
        return "#{link_to 'follow', 'JavaScript:void(0);', :onclick=>"follow_message(#{msg_id})"}"
      end
    end
  end
  
  def is_topic_followed(topic_id)
    flag = false;
    subject_id = 0
    topic_following_list().each do |t|
      if
        t.subject_id.equal?(topic_id)
        flag = true
        subject_id = t.id
        break
      end
    end
    if flag == true
      return "#{link_to 'unfollow', 'JavaScript:void(0);', :onclick=>"unfollow_topic(#{subject_id}, #{topic_id})"}"
    else
      return "#{link_to 'follow', 'JavaScript:void(0);', :onclick=>"follow_topic(#{topic_id})"}"
    end
  end
  def helper_most_latest_comment(comments)
    comments.first.body if comments
  end
  def helper_comment_length_exceeds?(latest_comment)
    latest_comment.length > 50
  end
  def helper_message_has_comments?(message)
    if message.comments.for_user(@current_user)
      return true
    end
    false
  end

  def helper_get_appropriate_voting(message)
    if !message.liking_by_user?(@current_user)
      return " - #{link_to 'Vote', 'JavaScript:void(0);', :onclick=>"vote_a_message(#{message.id})"}"
    end
  end

  def helper_get_appropriate_followship(message, page='feedwall')
    if current_user.following?(message)
      link_title = "unfollow"
      to_call = (page=='question_detail') ? "unfollow_message_detail_page('#{message.id.to_s}')" : "unfollow_message('#{message.id.to_s}')"
    else
      link_title = "follow"
      to_call = (page=='question_detail') ? "follow_message_detail_page('#{message.id.to_s}')" : "follow_message('#{message.id.to_s}')"
    end
    return "#{link_to link_title, 'JavaScript:void(0);', :onclick=>to_call}"
  end

  def helper_get_appropriate_followship_button(message)
    if @current_user.following?(message)
      image_title = 'un-follow-question-btn.png'
      to_call = "unfollow_message_detail_page('#{message.id.to_s}')"
    else
      image_title = 'theme/follow-question-btn.png'
      to_call = "follow_message_detail_page('#{message.id.to_s}')"
    end
    return  "#{link_to image_tag(image_title), 'JavaScript:void(0);', :onclick=> to_call}"
  end

  
  def is_comment_helpful(comment)
    liking = Liking.find_by_likeable_type_and_likeable_id_and_user_id("Comment",comment.id, @current_user.id )
    #    if liking.liking
    if comment.is_liked_by_user?(@current_user)
      return  "#{link_to 'Not Helpful','JavaScript:void(0);',:onclick=>"question_nothelpful(#{comment.id})"}"
    else
      return  "#{link_to 'Wicked Helpful', 'JavaScript:void(0);', :onclick=>"question_helpful(#{comment.id})"}"
    end
  end

  def is_comment_appropriate(comment, content)
    string = ""
    if content == "comment"
      string = "Answer"
    else
      string = "Question"
    end
    if Inappropriate.find_by_appropriable_type_and_appropriable_id_and_user_id(content, comment.id, @current_user.id).blank?
      return "#{link_to "Flag #{string} As Inappropriate", 'JavaScript:void(0);', :onclick=>"flag_as_inappropriate(#{comment.id}, '#{content}')"}"
    else
      appropriate = Inappropriate.find_by_appropriable_type_and_appropriable_id_and_user_id(content, comment.id, @current_user.id)
      if appropriate.is_answered
        return "#{link_to "Flag #{string} As Inappropriate", 'JavaScript:void(0);', :onclick=>"flag_as_inappropriate(#{comment.id}, '#{content}')"}"
      else
        return "#{link_to "Flag #{string} As Appropriate", 'JavaScript:void(0);', :onclick=>"flag_as_appropriate(#{comment.id}, '#{content}')"}"
      end
    end
  end
  #<%=link_to "Wickedstart Helpful", :controller=>"messages", :action=>"question_helpful", :id=>"#{comment.id}"%><!--<a href="#">Add Comment</a> | <a href="#">Wickedstart Helpful</a>--> | <%=link_to "No Helpful", :controller=>"messages", :action=>"question_nothelpful"%>
end