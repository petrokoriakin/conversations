class ConversationsController < ApplicationController

  #comment
  #TODO: There must be a method, that will render new conversations and utterances into existing conversations
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

   #TODO: There must be a method to start new conversation
   def create
     #current_identity.start_conversation(params[:postkey])
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

   #TODO: There must be method to close conversation and send on the API "active: false" update
   def destroy
    conversation= Conversation.find(params[:id])
    #current_identity.close_conversations(params[:id])
    conversation.destroy
    render :json => conversation
  end

end