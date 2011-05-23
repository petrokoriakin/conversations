class ConversationsController < ApplicationController
#comment
  def chatroom
     if rand(150) > 3
      render :nothing => true, :status => 404
    else
      sleep(rand(10));
      render :json =>{ :utterance => "Hi! Have a random number:  . #{rand 10}"}
    end
  end

  def index
     p current_identity
     render :json => Conversation.all
   end

   def show
     render :json => Conversation.find(params[:id])
   end

   def create
     conversation = Conversation.create! params
     render :json => conversation
   end

   #TODO: Use this method for adding new utterances
   def update
     conversation = Conversation.find(params[:id])
     #current_identity.add_utterance(params)
     conversation.update_attributes! params

     render :json => conversation
   end

   def destroy
    conversation= Conversation.find(params[:id])
    conversation.destroy
    render :json => conversation
  end

end