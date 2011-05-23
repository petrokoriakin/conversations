class SocialApiConnector
  class << self
    def use_alias(name, identity_id, identity_key)
      params = "identityID=#{identity_id}&identityKey=#{identity_key}&name=#{name}"
      response = execute_get('identity/useAlias', params)
      p  response.inspect
      unless response.blank?
        tmpresponse = ActiveSupport::JSON.decode(response)
        #existing_alias = tmpresponse["name"]
        #existing_alias.update_attributes(:identity_id => tmpresponse["identityID"], :identity_key => tmpresponse["identityKey"])
        tmpresponse
      else
        nil
      end
    end

    def alias_list(identity_id, identity_key)
      params = "identityID=#{identity_id}&identityKey=#{identity_key}"
      response = execute_get('identity/listAliases', params)
      ActiveSupport::JSON.decode(response)
    end

    def get_alias(name, identity_id, identity_key)
      params = "name=#{name}&identityID=#{identity_id}&identityKey=#{identity_key}"
      response = execute_get('identity/getAlias', params)
      ActiveSupport::JSON.decode(response)
    end
    
     def delete_alias(identity_id, identity_key)
      params = "identityID=#{identity_id}&identityKey=#{identity_key}"
      response = execute_get('identity/delete_alias', params)
      ActiveSupport::JSON.decode(response)
    end

    def new_alias(name, identity_id, identity_key)
      params = "identityID=#{identity_id}&identityKey=#{identity_key}&name=#{name}"
      response = execute_get('identity/addAlias', params)
      ActiveSupport::JSON.decode(response)
    end

    def add_identity(identity_id, identity_key,provider,name)
      params = "identityID=#{identity_id}&identityKey=#{identity_key}&name=#{name}&provider=#{provider}"
      response = execute_get('identity/mergeIdentity', params)
      ActiveSupport::JSON.decode(response)
    end
    
    def validate_identity(authority, profile_id)
      params = "authority=#{authority}&id=#{profile_id}"
      response = execute_get('identity/validate', params)
      unless response.blank?
        tmpresponse = ActiveSupport::JSON.decode(response)
        tmpresponse
      else
        nil
      end
    end

    def update(identity)
      params = "identityID=#{identity["identityID"]}&identityKey=#{identity["identityKey"]}"
      params += "&changes=#{ ActiveSupport::JSON.encode( :email => identity['email'], :avatar_url => identity['avatarURL'])}"
      response = execute_get('identity/update', params)
      ActiveSupport::JSON.decode(response)
    end

    #def update(identity_id, identity_key,hash)
      #changes = ActiveSupport::JSON.encode(hash)
      #params = "identityID=#{identity_id}&identityKey=#{identity_key}&changes=#{changes}"
      #response = execute_get('identity/update', params)
     # ActiveSupport::JSON.decode(response)
    #end

    def get_identity(identity_id, identity_key)
      params = "identityID=#{identity_id}&identityKey=#{identity_key}"
      response = execute_get('identity/get', params)
      ActiveSupport::JSON.decode(response)
    end

    def anonymous
      response = execute_get('identity/anonymous', params=nil)
      ActiveSupport::JSON.decode(response)
    end

    def update_alias(identityID, identityKey, hash)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&changes=#{ActiveSupport::JSON.encode(hash)}"
      response = execute_post('identity/update_alias', params)
      ActiveSupport::JSON.decode(response)
    end

    def delete(identityID, identityKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}"
      response = execute_post('identity/delete', params)
      ActiveSupport::JSON.decode(response)
    end

    def lookup(name)
      params = "name=#{name}"
      response = execute_post('identity/lookup', params)
      ActiveSupport::JSON.decode(response)
    end

    def add_favorite(identityID, identityKey, postKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}"
      response = execute_post('favorite/add', params)
      ActiveSupport::JSON.decode(response)
    end

    def get_favorites(identityID, identityKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}"
      response = execute_post('favorite/get', params)
      favors = ActiveSupport::JSON.decode(response)
      json = favors.collect{|favorite| {:postkey => favorite, :json => TapsConnector.find_item(favorite)}}
    end

    def remove_favorite(identityID, identityKey, postKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}"
      response = execute_post('favorite/remove', params)
      ActiveSupport::JSON.decode(response)
    end

    def add_saved_search(identityID, identityKey, searchURL, searchName)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&searchURL=#{searchURL}&searchName=#{searchName}"
      response = execute_post('saved_searches/add', params)
      ActiveSupport::JSON.decode(response)
    end

    def get_saved_searches(identityID, identityKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}"
      response = execute_post('saved_searches/get', params)
      ActiveSupport::JSON.decode(response)
    end

    def remove_saved_search(identityID, identityKey, searchID)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&searchID=#{searchID}"
      response = execute_post('saved_searches/remove', params)
      ActiveSupport::JSON.decode(response)
    end

    def update_saved_search(identityID, identityKey, searchID, name)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&searchID=#{searchID}&name=#{name}"
      response = execute_post('saved_searches/update', params)
      ActiveSupport::JSON.decode(response)
    end


    def add_flag(identityID, identityKey, postKey, flag, name = nil)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}&flag=#{flag[:code]}&comment=#{flag[:comment]}"
      params += "&name=#{name}" if name
      response = execute_post('posting/flag', params)
      ActiveSupport::JSON.decode(response)
    end

    def posting_get(postKey)
      params = "postKey=#{postKey}"
      response = execute_post('posting/get', params)
      ActiveSupport::JSON.decode(response)
    end

    def postings_get(postKey)
      params = "postingArray[postkey][]=#{postKey}"
      response = execute_post('posting/multiple_get', params)
      ActiveSupport::JSON.decode(response)
    end

    def set_owner(identityID, identityKey, postKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}"
      response = execute_post('posting/setOwner', params)
      ActiveSupport::JSON.decode(response)
    end


    def add_comment(identityID, identityKey, postKey, comment, replyToCommentID = nil, name = nil)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}&text=#{comment[:text]}"
      params += "&replyToCommentID=#{replyToCommentID}" if replyToCommentID
      params += "&name=#{name}" if name
      response = execute_get('comment/add', params)
      ActiveSupport::JSON.decode(response)
    end

    def remove_comment(identityID, identityKey, postKey, commentID)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}&commentID=#{commentID}"
      response = execute_get('comment/remove', params)
      ActiveSupport::JSON.decode(response)
    end

    def get_comments(postKey)
      params = "postKey=#{postKey}"
      response = execute_get('comment/get', params)
      ActiveSupport::JSON.decode(response)
    end

    def start_conversation(identityID, identityKey, postKey)
      params = "identityID=#{identityID}&identityKey=#{identityKey}&postKey=#{postKey}"
      response = execute_post('conversations/start', params)
      ActiveSupport::JSON.decode(response)
    end

    def list_conversations(identityID, identityKey, postKey = nil)
      params = "identityID=#{identityID}&identityKey=#{identityKey}"
      params += "&postKey=#{postKey}" if postKey
      response = execute_get('conversations/list', params)
      ActiveSupport::JSON.decode(response)
    end

    def add_utterance(conversationID, identityID, identityKey, text)
      params = "conversationID=#{conversationID}&identityID=#{identityID}&identityKey=#{identityKey}&text=#{text}"
      response = execute_post('conversations/add', params)
      ActiveSupport::JSON.decode(response)
    end

    def get_conversation(conversationID, identityID, identityKey, sinceUtteranceID = nil)
      params = "conversationID=#{conversationID}&identityID=#{identityID}&identityKey=#{identityKey}"
      params += "&sinceUtteranceID=#{sinceUtteranceID}" if sinceUtteranceID
      response = execute_get('conversations/get', params)
      ActiveSupport::JSON.decode(response)
    end

    def get_owner(post_key)
      posting = posting_get(post_key)
      if !posting["ownerID"].empty?
        identity = get_identity(posting["ownerID"], "FAKE-KEY")
      else
        nil
      end

    end

    def execute_post( path, params = nil )
      param = ""
      params.split(/[&=]/).each_with_index{|item,i| param << ((i % 2 == 0) ? "&" +  item : "=" + CGI.escape(item))} if params
      params =  param[1..-1]
      server = ServerConfig.social_api
      address = server + "/" + path
      ::Rails.logger.error "Curl-------------  " + "#{address}"
      ::Rails.logger.error params
      c = Curl::Easy.http_post("#{address}", params)
      c.body_str
    end

    def execute_get(path, params = nil)
      param = ""
      params.split(/[&=]/).each_with_index{|item,i| param << ((i % 2 == 0) ? "&" +  item : "=" + CGI.escape(item))} if params
      params =  param[1..-1]
      address = ServerConfig.social_api
      address += "/"
      address += params.present? ? path + '?' + params : path
      ::Rails.logger.error address
      ::Rails.logger.error "CURL----------------------------------------------  #{address}"
      curl = Curl::Easy.new(address)
      begin
        curl.perform
      rescue
        "Some Error with Request."
      end
      p "CURL--response-------#{curl.body_str}"
      curl.body_str
    end
  end
end
