
$(function() {
  window.Todo = Backbone.Model.extend({
    idAttribute: "_id",
    defaults: function() {
      return {
        done: false,
        order: Todos.nextOrder()
      };
    },
    toggle: function() {
      return this.save({
        done: !this.get("done")
      });
    }
  });
  window.TodoList = Backbone.Collection.extend({
    model: Todo,
    url: 'api/todos',
    done: function() {
      return this.filter(function(todo) {
        return todo.get('done');
      });
    },
    remaining: function() {
      return this.without.apply(this, this.done());
    },
    nextOrder: function() {
      if (!this.length) return 1;
      return this.last().get('order') + 1;
    },
    comparator: function(todo) {
      return todo.get('order');
    }
  });
  window.Todos = new TodoList;
  window.TodoView = Backbone.View.extend({
    tagName: 'li',
    template: _.template($('#item-template').html()),
    events: {
      "click.check": "toggleDone",
      "dblclick div.todo-text": "edit",
      "click span.todo-destroy": "clear",
      "keypress .todo-input": "updateOnEnter"
    },
    initialize: function() {
      this.model.bind("change", this.render, this);
      return this.model.bind("destory", this.remove, this);
    },
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      this.setText();
      return this;
    },
    setText: function() {
      var text;
      text = this.model.get('text');
      this.$('.todo-text').text(text);
      this.input = this.$('.todo-input');
      return this.input.bind('blur', _.bind(this.close, this)).val(text);
    },
    toggleDone: function() {
      return this.model.toggle();
    },
    edit: function() {
      $(this.el).addClass("editing");
      return this.input.focus();
    },
    close: function() {
      this.model.save({
        text: this.input.val()
      });
      return $(this.el).removeClass('editing');
    },
    updateOnEnter: function() {
      if (e.keyCode === 13) return this.close();
    },
    remove: function() {
      return $(this.el).remove();
    },
    clear: function() {
      return this.model.destory();
    }
  });
  window.AppView = Backbone.View.extend({
    el: $("#todoapp"),
    statsTemplate: _.template($('#stats-template').html()),
    events: {
      'keypress #new-todo': "createOnEnter",
      'keyup #new-todo': "showTooltip",
      'click .todo-clear a': "clearCompleted"
    },
    initialize: function() {
      this.input = this.$("#new-todo");
      Todos.bind('add', this.addOne, this);
      Todos.bind('reset', this.addAll, this);
      Todos.bind('all', this.render, this);
      return Todos.fetch();
    },
    render: function() {
      return this.$('#todo-stats').html(this.statsTemplate({
        total: Todos.length,
        done: Todos.done().length,
        remaining: Todos.remaining().length
      }));
    },
    addOne: function(todo) {
      var view;
      view = new TodoView({
        model: todo
      });
      return this.$('#todo-list').append(view.render().el);
    },
    addAll: function() {
      return Todos.each(this.addOne);
    },
    createOnEnter: function(e) {
      var text;
      text = this.input.val();
      if (!text || e.keyCode !== 13) return;
      Todos.create({
        text: text
      });
      return this.input.val("");
    },
    clearCompleted: function() {
      _.each(Todos.done(), function(todo) {
        return todo.destroy();
      });
      return false;
    },
    showTooltip: function(e) {
      var show, tooltip, val;
      tooltip = this.$(".ui-tooltip-top");
      val = this.input.val();
      tooltip.fadeOut();
      if (this.tooltipTimeout) clearTimeout(this.tooltipTimeout);
      if (val === '' || val === this.input.attr('placeholder')) return;
      show = function() {
        return tooltip.show().fadeIn();
      };
      return this.tooltipTimeout = _.delay(show, 1000);
    }
  });
  return window.App = new AppView;
});
