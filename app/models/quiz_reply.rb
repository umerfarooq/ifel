class QuizReply < ActiveRecord::Base
  belongs_to :quiz
  has_many :answers

  accepts_nested_attributes_for :answers

  ROUTES_REGEX = /is-my-idea-viable|am-i-an-entrepreneur/i

  attr_accessible :email, :comment, :answers_attributes, :question_id

  def QuizReply.new_with_quiz(quiz)
    qr = QuizReply.new
    qr.quiz = quiz
    qr.quiz.questions.published.each do |q|
      qr.answers.build(:question_id => q.id)
    end
    return qr
  end

  def QuizReply.associate_questions_to_answers(quiz_reply)
      quiz_reply.quiz.questions.published.each_with_index do |q, counter|
      quiz_reply.answers[counter].question_id = q.id
    end
    return quiz_reply
  end

  def point_based?
    self.quiz.point_based?
  end

  def score
    self.answers.sum(:score)
  end

  def deliver_quiz_reply_email
    AdminMailer.deliver_quiz_reply_email(self)
  end
end
