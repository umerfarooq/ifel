class MarketingMultimediaMessagesController < ApplicationController
  def index
    @marketing_multimedia_messages = MarketingMultimediaMessage.all
  end

  def play
#    @multimedia_path = params[:multimedia]
#    render :layout => false
    video_path = params[:multimedia]
    return render :partial => 'shared/flvplayer', :locals => { :video_path => video_path, :width => nil, :height => nil, :padding => nil }
  end

  def show
    @marketing_multimedia_message = MarketingMultimediaMessage.find params[:id]
    render :layout => false
  end

  def new
    @marketing_multimedia_message = MarketingMultimediaMessage.new
  end

  def create
    @marketing_multimedia_message = MarketingMultimediaMessage.new params[:marketing_multimedia_message]
#    @marketing_multimedia_message.state = State.find_by_name('inactivate')
    if @marketing_multimedia_message.save
      flash[:notice] = "Multimedia Message successfully added."
      return redirect_to marketing_multimedia_messages_url
    else
      render :action => 'new'
    end
  end

  def edit
    @marketing_multimedia_message = MarketingMultimediaMessage.find params[:id]
  end

  def update
    @marketing_multimedia_message = MarketingMultimediaMessage.find params[:id]
     if @marketing_multimedia_message.update_attributes(params[:marketing_multimedia_message])
      flash[:notice] = "Message updated successfully."
      return redirect_to marketing_multimedia_messages_url
    else
      render :action => 'edit'
    end
  end

end
