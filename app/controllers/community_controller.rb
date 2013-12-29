class CommunityController < ApplicationController
  before_filter :require_user
  before_filter :require_payment
  before_filter { |c| c.active_tab=:community }
  before_filter :set_new_design_theme, :only => [:index]

  def index

#         @community_question = CommunityQuestion.create(:section_id => params[:title], :text => parms[:message])
#     respond_to do |format|
#       if @community_question.save
#         format.html { redirect_to posts_path }
#         format.js
#       else
#         flash[:notice] = "Message failed to save."
#         format.html { redirect_to posts_path }
#       end
#     end
   end

  def show

  end

  def new
    @community_question = CommunityQuestion.new
  end

  def create
    @community_question = CommunityQuestion.create(:section_id => params[:title], :text => parms[:message])
        respond_to do |format|
       if @community_question.save
         format.html { redirect_to community_path }
         format.js
       else
         flash[:notice] = "Message failed to save."
         format.html { redirect_to community_path }
       end
     end
  end

  def edit
  end

  def list_topics
    @items = Item.find(params[:id_tittle])



  end

end
