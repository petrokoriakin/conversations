class ConversationsController < ApplicationController

  #comment
  #TODO: There must be a method, that will render new conversations and utterances into existing conversations
  def chatroom

    #[{"conversationID"=>"3",
    #"ownerID"=>"2",
    # "otherPartyID"=>"12",
    # "postKey"=>"BUHMR85",
    # "utterances"=>[{"utteranceID"=>"4", "authorID"=>"12", "text"=>"olololo", "timestamp"=>"2011-05-19 13:30:04 UTC"},
    #                {"utteranceID"=>"5", "authorID"=>"12", "text"=>"one more utterance", "timestamp"=>"2011-05-23 12:52:08 UTC"}]
    #  },
    #  {"conversationID"=>"4",
    #   "ownerID"=>"2",
    #   "otherPartyID"=>"12",
    #   "postKey"=>"BUGMW9M",
    #   "utterances"=>[{"utteranceID"=>"6", "authorID"=>"12", "text"=>"go go go", "timestamp"=>"2011-05-23 13:20:28 UTC"},
    #                   {"utteranceID"=>"7", "authorID"=>"12", "text"=>"how mutch?", "timestamp"=>"2011-05-23 13:20:44 UTC"}]
    #  }
    #]
    #
    #current_identity.get_conversations
     if rand(150) > 3
      render :nothing => true, :status => 404
    else
      sleep(rand(10));
      render :json =>  [{"conversationID"=>"3",
    "ownerID"=>"2",
     "otherPartyID"=>"12",
     "postKey"=>"BUHMR85",
     "utterances"=>[{"utteranceID"=>"4", "authorID"=>"12", "text"=>"olololo", "timestamp"=>"2011-05-19 13:30:04 UTC"},
                    {"utteranceID"=>"5", "authorID"=>"12", "text"=>"one more utterance", "timestamp"=>"2011-05-23 12:52:08 UTC"}]
      },
      {"conversationID"=>"4",
       "ownerID"=>"2",
       "otherPartyID"=>"12",
       "postKey"=>"BUGMW9M",
       "utterances"=>[{"utteranceID"=>"6", "authorID"=>"12", "text"=>"go go go", "timestamp"=>"2011-05-23 13:20:28 UTC"},
                       {"utteranceID"=>"7", "authorID"=>"12", "text"=>"how mutch?", "timestamp"=>"2011-05-23 13:20:44 UTC"}]
      }
    ]
    end
  end

  def index
     p current_identity
     render :json =>  [{"conversationID"=>"3",
    "ownerID"=>"2",
     "otherPartyID"=>"12",
     "postKey"=>"BUHMR85",
     "utterances"=>[{"utteranceID"=>"4", "authorID"=>"12", "text"=>"olololo", "timestamp"=>"2011-05-19 13:30:04 UTC"},
                    {"utteranceID"=>"5", "authorID"=>"12", "text"=>"one more utterance", "timestamp"=>"2011-05-23 12:52:08 UTC"}]
      },
      {"conversationID"=>"4",
       "ownerID"=>"2",
       "otherPartyID"=>"12",
       "postKey"=>"BUGMW9M",
       "utterances"=>[{"utteranceID"=>"6", "authorID"=>"12", "text"=>"go go go", "timestamp"=>"2011-05-23 13:20:28 UTC"},
                       {"utteranceID"=>"7", "authorID"=>"12", "text"=>"how mutch?", "timestamp"=>"2011-05-23 13:20:44 UTC"}]
      }
    ]
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