// An example Backbone application contributed by
// [Jérôme Gravel-Niquet](http://jgn.me/). This demo uses a simple
// [LocalStorage adapter](backbone-localstorage.html)
// to persist Backbone models within your browser.

// Load the application once the DOM is ready, using `jQuery.ready`:
function isEmpty(object) {
    for(var i in object) {return false;}
    return true;
}

// extend underscore a bit
_.mixin({

  isDefined: function(obj) {
    !_.isUndefined(obj);
  },

  isPresent: function(obj) {
    !_.isEmpty(obj);
  },

  commatizeNumber: function(num) {
    if(_.isNumber(num)) num = num.toString();
    var commatized = '';
    for(var i = num.length - 1, j = 1; i > 0; --i, j++) {
      commatized = num.charAt(i) + commatized;
      if(j % 3 == 0) {
        commatized = ',' + commatized;
      }
    }
    commatized = num.charAt(0) + commatized;
    return commatized;
  },

  cacheBuster: function() {
    return new Date().getTime();
  },

  trim: function(str) {
    return str.replace(/^\s*|\s*$/g,'');
  }

});

$(function(){


window.Utterance = Backbone.Model.extend({

  url : function() {
    return this.id ? '/todos/' + this.id : '/todos';
  }

});

  window.UtteranceList = Backbone.Collection.extend({

    model: Utterance,
    url :'/todos',

    nextUtteranceID: function() {
      if (!this.length) return 1;
      return this.last().get('utteranceID') + 1;
    },

    comparator: function(todo) {
      return todo.get('utteranceID');
    }

  });

  window.Utterances = new UtteranceList;

  window.UtteranceView = Backbone.View.extend({

    tagName:  "li",

    template: _.template($('#utterance-template').html()),

    initialize: function() {
      _.bindAll(this, 'render', 'close');
      this.model.bind('change', this.render);
      this.model.view = this;
    },

    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      this.setText();
      return this;
    },

    setText: function() {
      var text =  'Author ' + this.model.get('authorID') + ': ' + this.model.get('text');
      this.$('.utterance').text(text);

    }
  });

  window.AppView = Backbone.View.extend({

    el: $("#todoapp"),

    events: {
      "keypress #new-todo":  "createOnEnter"
    },

    initialize: function() {
      _.bindAll(this, 'addOne', 'addAll', 'render');

      this.input    = this.$("#new-todo");

      Utterances.bind('add',     this.addOne);
      Utterances.bind('refresh', this.addAll);
      Utterances.bind('all',     this.render);

      Utterances.fetch();
      this.startListConversations();
    },

    render: function() {
    },

    addOne: function(todo) {
      var view = new UtteranceView({model: todo});
      this.$("#todo-list").append(view.render().el);
    },

    addAll: function() {
      Utterances.each(this.addOne);
    },

    newAttributes: function() {
      return {
        text: this.input.val(),
        utteranceID:   Utterances.nextUtteranceID()
      };
    },

    createOnEnter: function(e) {
      if (e.keyCode != 13) return;
      Utterances.create(this.newAttributes());
      this.input.val('');
    }
  });

  // Todo Model

window.Conversation = Backbone.Model.extend({

  defaults: {
      content: "empty utterace...",
      done: false
  },

  initialize: function() {
    if (!this.get("content")) {
      this.set({"content": this.EMPTY});
    }
  },

  //TODO: Implement utterances proccessing right here
  toggle: function() {
    this.save({done: !this.get("done")});
  },

  url : function() {
    return this.id ? '/conversations/' + this.id : '/conversations';
  },

  clear: function() {
    this.destroy();
    this.view.remove();
  }

});

  // Todo Collection
  // ---------------

  // The collection of todos is backed by *localStorage* instead of a remote
  // server.
  window.ConversationList = Backbone.Collection.extend({

    // Reference to this collection's model.
    model: Conversation,
    url :'/conversations',
    // Save all of the todo items under the `"todos"` namespace.
    //localStorage: new Store("todos"),

    // Filter down the list of all todo items that are finished.
    done: function() {
      return this.filter(function(conversation){ return conversation.get('done'); });
    },

    // Filter down the list to only todo items that are still not finished.
    remaining: function() {
      return this.without.apply(this, this.done());
    },

    // We keep the Todos in sequential order, despite being saved by unordered
    // GUID in the database. This generates the next order number for new items.
    nextOrder: function() {
      if (!this.length) return 1;
      return this.last().get('order') + 1;
    },

    // Todos are sorted by their original insertion order.
    comparator: function(conversation) {
      return conversation.get('order');
    }

  });

  // Create our global collection of **Todos**.
  window.Conversations = new ConversationList;

  // Todo Item View
  // --------------

  // The DOM element for a todo item...
  window.ConversationView = Backbone.View.extend({

    //... is a list tag.
    tagName:  "li",

    // Cache the template function for a single item.
    template: _.template($('#item-template').html()),

    // The DOM events specific to an item.
    events: {
      "click .check"              : "toggleDone",
      "click button#submit"       : "send",
      "click span.todo-destroy"   : "clear",
      "keypress .todo-input"      : "updateOnEnter"
    },

    // The TodoView listens for changes to its model, re-rendering. Since there's
    // a one-to-one correspondence between a **Todo** and a **TodoView** in this
    // app, we set a direct reference on the model for convenience.
    initialize: function() {
      _.bindAll(this, 'render', 'close');
      this.model.bind('change', this.render);
      this.model.view = this;
    },

    // Re-render the contents of the todo item.
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      this.setContent();
      return this;
    },

    // To avoid XSS (not that it would be harmful in this particular app),
    // we use `jQuery.text` to set the contents of the todo item.
    setContent: function() {
      var content = this.model.get('content');
      this.$('.todo-content').text(content);
      this.input = this.$('.todo-input');
      this.input.bind('blur', this.close);
      this.input.val(content);
    },

    // Toggle the `"done"` state of the model.
    toggleDone: function() {
      this.model.toggle();
    },

    // Switch this view into `"editing"` mode, displaying the input field.
    send: function() {
      var self = $(this.el);
      var utterance = $('.conversation-textarea', self).val();

      var last = $('#conversation-message-box.utterance-last', self);
      $('#conversation-message-box.utterance-last', self).html(utterance);
      $('#conversation-message-box.utterance-last', self).removeClass('utterance-last');
      last.append('<div id=\"utterance-last\"></div>');

      this.model.save({content: utterance});
//      $.ajax({
//         url: '/conversations/update?conversationID=' + this.model.get('conversationID') + '&text=' + utterance,
//         dataType: 'json',
//         success: function(data){
//         }
//      });
    },

    // Close the `"editing"` mode, saving changes to the todo.
    close: function() {
      this.model.save({content: this.input.val()});
      $(this.el).removeClass("editing");
    },

    // If you hit `enter`, we're through editing the item.
    updateOnEnter: function(e) {
      if (e.keyCode == 13) this.close();
    },

    // Remove this view from the DOM.
    remove: function() {
      $(this.el).remove();
    },

    // Remove the item, destroy the model.
    clear: function() {
      this.model.clear();
    }

  });

  // The Application
  // ---------------

  // Our overall **AppView** is the top-level piece of UI.
  window.AppView = Backbone.View.extend({

    // Instead of generating a new element, bind to the existing skeleton of
    // the App already present in the HTML.
    el: $("#todoapp"),

    // Our template for the line of statistics at the bottom of the app.
    statsTemplate: _.template($('#stats-template').html()),

    // Delegated events for creating new items, and clearing completed ones.
    events: {
      "keypress #new-todo":  "createOnEnter",
      "keyup #new-todo":     "showTooltip",
      "click .todo-clear a": "clearCompleted"
    },

    // At initialization we bind to the relevant events on the `Todos`
    // collection, when items are added or changed. Kick things off by
    // loading any preexisting todos that might be saved in *localStorage*.
    initialize: function() {
      _.bindAll(this, 'addOne', 'addAll', 'render');

      this.input    = this.$("#new-todo");

      Conversations.bind('add',     this.addOne);
      Conversations.bind('refresh', this.addAll);
      Conversations.bind('all',     this.render);

      Conversations.fetch();
      this.startListConversations();
    },

    // Re-rendering the App just means refreshing the statistics -- the rest
    // of the app doesn't change.
    render: function() {
      var done = Conversations.done().length;
      this.$('#todo-stats').html(this.statsTemplate({
        total:      Conversations.length,
        done:       Conversations.done().length,
        remaining:  Conversations.remaining().length
      }));
    },

    // Add a single todo item to the list by creating a view for it, and
    // appending its element to the `<ul>`.
    addOne: function(conversation) {
      var view = new ConversationView({model: conversation});
      this.$("#todo-list").append(view.render().el);
    },

    // Add all items in the **Todos** collection at once.
    addAll: function() {
      Conversations.each(this.addOne);
    },

    // Generate the attributes for a new Todo item.
    newAttributes: function() {
      return {
        content: this.input.val(),
        order:   Conversations.nextOrder(),
        done:    false
      };
    },

    // If you hit return in the main input field, create new **Todo** model,
    // persisting it to *localStorage*.
    createOnEnter: function(e) {
      if (e.keyCode != 13) return;
      Conversations.create(this.newAttributes());
      this.input.val('');
    },

    // Clear all done todo items, destroying their models.
    clearCompleted: function() {
      _.each(Conversations.done(), function(conversation){ conversation.clear(); });
      return false;
    },

    // Lazily show the tooltip that tells you to press `enter` to save
    // a new todo item, after one second.
    showTooltip: function(e) {
      var tooltip = this.$(".ui-tooltip-top");
      var val = this.input.val();
      tooltip.fadeOut();
      if (this.tooltipTimeout) clearTimeout(this.tooltipTimeout);
      if (val == '' || val == this.input.attr('placeholder')) return;
      var show = function(){ tooltip.show().fadeIn(); };
      this.tooltipTimeout = _.delay(show, 1000);
    },

    // Generate the attributes for a new Todo item.
    gotAttributes: function(text) {
      return {
        content: text,
        order:   Conversations.nextOrder(),
        done:    false
      };
    },

    startListConversations: function() {
      function listConversations(){
      if (listConversationsStarted){
        var started_at = _.cacheBuster();
        var request = $.ajax({
          cache: false,
          url: '/conversations/chatroom',
          dataType: 'json',
          success: function(data, status, jqXHR){
              Conversations.create({content: data.utterance, order: Conversations.nextOrder(), done: false});
          },
          error: function(){
          },
          complete: function(jqXHR){
             var complited_at = _.cacheBuster();
             // PyotrK: Please, keep this for debug mode
             //var time_differense = 50000 - (complited_at - started_at);
             var time_differense = 5000 - (complited_at - started_at);
             if (time_differense > 0) {
                setTimeout(function() {
                    listConversations();
                }, time_differense );
             } else {
               listConversations();
             }
          }
        });
      } else {
        setTimeout( function(){
            listConversations();
        }, 5000 );
      }
    }
    listConversations();
    }

  });

  // Finally, we kick things off by creating the **App**.
  window.App = new AppView;

});
