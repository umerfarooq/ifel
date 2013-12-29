module QuizRepliesHelper
  def result_heading_for(quiz_reply)
    if quiz_reply.point_based?
      if quiz_reply.score > 35
        "Congratulations! You scored #{quiz_reply.score}"
      else
        "You scored #{quiz_reply.score}"
      end
    else
      case quiz_reply.score
      when 6, 5
        "Congratulations!"
      when 4, 3
        "Your idea has potential. . ."
      when 2, 1
        "Your idea may be viable. . ."
      when 0
        "Sorry, you're idea is not viable"
      end
    end
  end

  def result_first_paragraph_for(quiz_reply)
    if quiz_reply.point_based?
      case quiz_reply.score
      when 48..60
        "If you earned between 48 and 60 points, then you have many of the " +
          "necessary attributes for an entrepreneur. You should feel free to " +
          "start you business planning process."
      when 36..47
        "If you earned between 36 and 47 points, you have the potential to be " +
          "an entrepreneur. However, you should address your skills in areas " +
          "where you didn't answer a 2 or 3. You can either improve yourself, " +
          "find a business partner or hire someone with these skills to " +
          "complement you in areas where you didn't indicate a 2 or 3."
      else
        "If you earned 35 or fewer points, then being an entrepreneur may not " +
          "be right for you. While you can improve in areas where you didn't " +
          "earn 2 or 3, this may require a lot of self improvement. You might " +
          "be more successful and happier working for somebody else or for an " +
          "established company, however, only you can make that decision."
      end
    else
      responses = quiz_reply.answers.wrong.sort_by{|a| a.question.sequence_number}.collect{|a| a.question.response_no }
      case quiz_reply.score
      when 6
        "Congratulations! You answered \"Yes\" to all six questions on the quiz, " +
          "so your idea is viable. I believe you've given consideration to the key " +
          "elements necessary for starting a business."
      when 5
        "Congratulations! You answered \"Yes\" to five questions on the quiz, " +
          "so your idea is viable. I think you've given consideration to most of the key " +
          "elements necessary for starting a business."
      when 4
        "You're idea has potential, so yes, I think you're idea is viable, " +
          "but you need to #{responses[0]} and #{responses[1]}. You have some more " +
          "homework to do in scoping out your idea but you're on the right track."
      when 3
        "You're idea has potential, so yes, I think you're idea is viable, " +
          "but you need to #{responses[0]}, #{responses[1]} and #{responses[2]}. " +
          "You have some more homework to do in scoping out your idea but you're " +
          "on the right track. Spending more time addressing these issues will help you " +
          "think about how you can ultimately get your idea off the ground successfully."
      when 2
        "You're idea may be viable, however you answered \"No\" to four of the questions " +
          "on the quiz. You need to #{responses[0]}, #{responses[1]} and #{responses[2]}. " +
          "You have some homework to do in further developing your idea. Spending more " +
          "time addressing these issues will help you think about how you can ultimately " +
          "get your idea off the ground successfully. If you can make progress and ultimately " +
          "answer \"Yes\" to at least one or two of these issues, your idea has potential."
      when 1
        "You're idea may be viable, however you answered \"No\" to five of the questions " +
          "on the quiz. You need to #{responses[0]}, #{responses[1]} and #{responses[2]}. " +
          "You have homework to do in further developing your idea. Spending more time " +
          "addressing these issues will help you think about how you can ultimately get " +
          "your idea off the ground successfully. If you can make progress and ultimately " +
          "answer \"Yes\" to at least two or three of these issues, your idea has potential."
      when 0
        "Sorry, you're idea is not viable. You answered \"No\" to all six questions " +
          "on the quiz. If you're serious about starting a business, then you've got " +
          "homework to do. Spending more time addressing these issues will help you " +
          "think about how you can ultimately get your idea off the ground successfully. " +
          "Try doing more research and\/or changing your assumptions so that you can " +
          "answer \"Yes\" to at least three of the quiz questions."
      end
    end
  end

  def result_second_paragraph_for(quiz_reply)
    if quiz_reply.point_based?
      if quiz_reply.score > 35
        "To see how Wicked Start can help you manage the process of starting a business, " +
          "#{link_to('click here', ((Feature.get_parents.published.first.blank?) ? features_path : detail_feature_path(Feature.get_parents.published.first)))}, " +

          unless $is_ws_free_as_default
            "or try it for a 7-days free."
          else
            "or sign up for a free account now."
          end
      end
    else
      case quiz_reply.score
      when 6, 5, 4, 3, 2
        "Let Wicked Start help you manage the process of starting a business. " +
          link_to("Click here", ((Feature.get_parents.published.first.blank?) ? features_path : detail_feature_path(Feature.get_parents.published.first))) +
          " to see How It Works or Sign Up now."
      when 1
        "If you think you're ready to start your business planning process, let Wicked Start help. " +
          link_to("Click here", ((Feature.get_parents.published.first.blank?) ? features_path : detail_feature_path(Feature.get_parents.published.first))) +
          " to see How It Works or Sign Up now."
      when 0
        "When you're ready to start planning a business, you can use " +
          "Wicked Start to help you get your business off the ground."
      end
    end
  end

  def make_features_url(url, hostname)
    hostname.concat(url)
  end

end
