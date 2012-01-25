$( ->
  window.Todo = Backbone.Model.extend
    idAttribute: "_id"
    defaults: ->
      done: false
      order: Todos.nextOrder()

    toggle: ->
      @.save {done: !@.get("done")}

  window.TodoList = Backbone.collection.extend
    model: Todo
    url: 'api/todos'
    done: ->
      @filter (todo) ->
        todo.get('done')
    remaining: ->
      @.without.apply( @, @.done)
    nextOrder: ->
      return 1 if !@.length
      @.last().get('order') + 1
    comparator: (todo) ->
      todo.get('order')

  window.Todos = new TodoList;

  window.TodoView = Backbone.View.extend
    tagName: 'li'
    template: _.template($('#item_template').html())
    events:
      "click.check"             : "toggleDone"
      "dblclicl div.todo-text"  : "edit"
      "click span.todo-destroy" : "clear"
      "keypress .todo-input"    : "updateOnEnter"

    initialize: ->
      @model.bind("change", @render, @)
      @model.bind("destory", @remove, @)

    render: ->
      $(@el).html(@template(@model.toJSON()))
      @.setText()
      @

    setText: ->
      text = @model.get('text')
      @.$('.todo-text').text(text)
      @.input = @.$('.todo-input')
      @.input.bind('blur', _.bind(@.close, @)).val(text)

    toggleDone: ->
      @model.toggle()

    edit: ->
      $(@el).addClass("editing")
      @.input.focus()

    close: ->
      @model.save({text: @.input.val()})
      $(@el).removeClass('editing')

    updateOnEnter: ->
      @.close() if e.keyCode == 13

    remove: ->
      $(@el).remove()

    clear: ->
      @model.destory()

  window.AppView = Backbone.View.extend
    el: $("#todoapp")
    statsTemplate: _.template($('#stats_template').html())
    events:
      'keypress #new-todo': "createOnEnter"
      'keyup #new-todo': "showTooltip"
      'click .todo-clear a': "clearCompleted"

    initialize: ->
      @input = @.$("#new-todo")
      Todos.bind('add', @.addOne, @)
      Todos.bind('reset', @.addAll, @)
      Todos.bind('all', @.render, @)
      Todos.fetch()

    render: ->
      @.$('#todo-stats').html @.statsTemplate
        total: Todos.length
        done:  Todos.done().length
        remaining: Todos.remaining().length

    addOne: (todo) ->
      view = new TodoView {model: todo}
      @.$('#todo-list').append(view.render().el)

    addAll: ->
      Todos.each(@.addOne)

    createOnEnter: (e) ->
      text = @.input.val()
      return if (!text || e.keyCode != 13 )
      Todos.create(text: text)
      @.input.val("")

    clearCompleled: ->
      _.each Todos.done(), (todo) ->
        todo.destroy()
      false

    showTooltip: (e) ->
      tooltip = @.$(".ui-tooltop-top")
      val = @.input.val()
      tooltip.faceOut()
      clearTimeout(@.tooltipTimeout) if (@.tooltipTimeout)
      return if val == '' || val == @.input.attr('placeholder')
      show = ->
        tooltip.show().fadeIn()
      @tooltipTimeout = _.delay(show, 1000)

  window.App = new AppView

)
