class Identity < Struct.new(:provider, :name, :anonymous, :identityID, :identityKey, :email, :avatarURL, :aliases, :facebookID, :googleID, :twitterID, :linkedinID, :conversations)
  def self.from_hash(hash)
    hash = hash.with_indifferent_access
    Identity.new(
      hash[:provider],
      hash[:name],
      hash[:anonymous],
      hash[:identityID],
      hash[:identityKey],
      hash[:email],
      hash[:avatarURL],
      hash[:aliases],
      hash[:facebookID],
      hash[:googleID],
      hash[:twitterID],
      hash[:linkedinID],
      hash[:conversations]
    )
  end

  def self.anonymous
    temp_identity = SocialApiConnector.anonymous
    identity = self.new()
    identity.identityID = temp_identity["identityID"]
    identity.identityKey = temp_identity["identityKey"]
    identity.twitterID = nil
    identity.facebookID = nil
    identity.googleID = nil
    identity.linkedinID = nil
    identity.aliases = nil
    identity.avatarURL = nil
    identity.anonymous = true
    identity.conversations = {}
    identity
  end

  def new_alias(name)
    hash = SocialApiConnector.new_alias(name, identityID, identityKey)
    if hash
      Identity.from_hash(hash)
    else
      nil
    end
  end

  def alias_list
    SocialApiConnector.alias_list(identityID, identityKey)
  end

  def add_identity(provider,name)
    SocialApiConnector.add_identity(identityID, identityKey,provider,name)
  end
  
  # Method for notifying the API that the identity alias is used
  def use(name = nil)
    if name.nil?
      SocialApiConnector.use_alias(self.name, identityID, identityKey)
    else
      hash = SocialApiConnector.get_alias(name, identityID, identityKey)
      Identity.from_hash(hash)
    end
  end

  def get_alias
    SocialApiConnector.get_alias(name, identityID, identityKey)
  end

  def delete_alias(_alias)
    _alias = SocialApiConnector.get_alias(_alias, identityID, identityKey)
    if _alias
      response = SocialApiConnector.delete_alias(_alias["identityID"], _alias["identityKey"])
      #aliases.delete(name) if response["success"]
      response
    else
      nil
    end
  end

  def update(hash)
    SocialApiConnector.update_alias(identityID, identityKey, hash)
  end

  def destroy
    SocialApiConnector.delete(identityID, identityKey)
  end

  def username
    response =  SocialApiConnector.get(identityID, identityKey)
    response["name"]
  end

  def lookup(name)
    SocialApiConnector.lookup(name)
  end

  def self.create_from_hash(hash)
    name = case hash['provider']
    when 'twitter'
      "@" + hash['user_info']['nickname']
    when 'facebook'
      hash['extra']['user_hash']['name']
    when 'google'
      hash['user_info']['email']
    when 'linked_in'
      hash['user_info'][:name]
    end

    identity = self.new(hash['provider'], name)
    if identity.valid?(hash)
      identity
    else
      nil
    end
  end

  def to_hash
    identity = SocialApiConnector.get_alias(self.identityID, self.identityKey)
    #user = SocialApiConnector.get_identity(self.identityID, self.identityKey)
    #alias_list = SocialApiConnector.alias_list(self.identityID, self.identityKey)
    self.name = identity["name"]
    self.email = identity["email"]
    self.avatarURL = identity["avatarURL"]
    self.aliases = identity["aliases"]
    {
      "identityID" => self.identityID,
      "identityKey" => self.identityKey,
      "name" => self.name,
      "anonymous" => self.anonymous,
      "twitterID" => self.twitterID,
      "facebookID" => self.facebookID,
      "googleID" => self.googleID,
      "linkedinID" => self.linkedinID,
      "email" => self.email,
      "avatarURL" => self.avatarURL,
      "aliases" =>  self.aliases,
      "conversations" => {}
    }
  end

  def valid?(hash)
    if validate_identity_response = SocialApiConnector.validate_identity(hash['provider'], self.name)
      self.identityID = validate_identity_response["identityID"]
      self.identityKey = validate_identity_response["identityKey"]
      self.twitterID = validate_identity_response["twitterID"]
      self.facebookID = validate_identity_response["facebookID"]
      self.googleID = validate_identity_response["googleID"]
      self.linkedinID = validate_identity_response["linkedinID"]
      self.aliases = validate_identity_response["aliases"]
      self.avatarURL = validate_identity_response["avatarURL"]
      self.conversations = {}

      update_info(hash) if new? 

      self.anonymous = false
      return true
    end
    false
  end

  def new?
    get_response = SocialApiConnector.get_identity(self.identityID, self.identityKey)
    p get_response.inspect
    get_response["name"].nil? || get_response["avatarURL"].blank?
  end

  def update_info(hash)
    case hash['provider']
    when 'twitter'
      avatar_url = hash['user_info']['image'].gsub!(/_normal/, "")
      website_url = hash['user_info']['urls']['Website']
    when 'facebook'
      avatar_url = "http://graph.facebook.com/#{hash['uid']}/picture"
      website_url =  hash['user_info']['urls']['Website']
    when 'google'
      if name = account_name = hash.try(:[],'user_info').try(:[], 'email')
        account_name = name.gsub(/@[\w\W]*$/, '')
        c = Curl::Easy.new("https://www.googleapis.com/buzz/v1/people/#{account_name}/@self")
        if c.perform
          google_profile = Hash.from_xml(c.body_str)
          avatar_url = google_profile.try(:[], "entry").try(:[], "photos").try(:[], 1).try(:[], "value")
        end
      end
      avatar_url ||= ""
      website_url = ""
    when 'linked_in'
      avatar_url = hash['user_info']['image']
      website_url = ""
    end
    self.avatarURL = avatar_url
    update_hash = {
      :name => self.name,
      :avatar_url => avatar_url,
      :website_url => website_url
    }
    SocialApiConnector.update_alias(self.identityID, self.identityKey, update_hash)
  end

  def self.update_profile(preview_identity, new_identity)
    SocialApiConnector.update(preview_identity, {new_identity['provider'] => new_identity['name']} )
  end

  def change_email(email)
    SocialApiConnector.update
  end

  ### Favorites

  def add_favorite(key)
    SocialApiConnector.add_favorite(identityID, identityKey, key)
  end

  def remove_favorite(key)
    SocialApiConnector.remove_favorite(identityID, identityKey, key)
  end

  ### Saved Searches

  def add_saved_search(url, name)
    SocialApiConnector.add_saved_search(identityID, identityKey, url, name)
  end

  def update_saved_search(id, name)
    SocialApiConnector.update_saved_search(identityID, identityKey, id, name)
  end

  def remove_saved_search(id)
    SocialApiConnector.remove_saved_search(identityID, identityKey, id)
  end

  ### Conversations

  def start_conversation(postkey)
    #response = {"conversationID"=>"2", "ownerID"=>"2", "otherPartyID"=>"12", "postKey"=>"BUHMR85", "utterances"=>[{}]}
    if new_conversation = SocialApiConnector.start_conversation(identityID, identityKey, postkey)
      conversations[new_conversation["conversationID"]] = false
    end
    new_conversation
  end

  def add_utterance(conversationID, text)
    #utterance = {"id"=>4}
    if utterance = SocialApiConnector.add_utterance(conversationID, identityID, identityKey, text)
      conversations[conversationID] = utterance["id"]
    end
    utterance
  end

  def get_conversation(conversationID)
    SocialApiConnector.get_conversation(conversationID, identityID, identityKey)
  end

  def list_conversations
    # conversation_list = [{"conversationID"=>"3", "ownerID"=>"2", "otherPartyID"=>"12", "postKey"=>"BUHMR85", "utterances"=>[{}]}]
    conversation_list = SocialApiConnector.list_conversations(identityID, identityKey)
    unless conversation_list[0].blank?
      conversation_list.each do |conversation|
        last_utterance = conversation["utterances"].last.try(:[], "utteranceID")
        conversations[conversation["conversationID"]] = last_utterance ?  last_utterance : false
      end
    end
    conversation_list
  end

  def get_conversations
    #conversations.each do |conversation|

    #end
  end

end
