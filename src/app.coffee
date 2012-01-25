application_root = __dirname
express = require "express"
path = require "path"
mongoose = require "mongoose"

app = express.createServer()

mongoose.connect 'mongodb://localhost/todo-coffee'

Todo = mongoose.model 'Todo', new mongoose.Schema({
  text: String,
  done: Boolean,
  order: Number
})

app.configure ->
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.router)
  app.use(express.static(path.join(application_root, "public")))
  app.use(express.errorHAndler({ dumpExceptions: true, showStack: true}))
  app.set('views', path.join(application_root, "views"))
  app.set('view_engine', 'jade')


app.get 'api/todos', (req, res) ->
  Todo.find (err, todos) ->
    res.send(todos)

app.get 'api/todos/:id', (res, req) ->
  Todo.findById req.params.id, (err, todo) ->
    todo.text = req.body.text
    todo.done = req.body.done
    todo.order = req.body.order
    todo.save (err) ->
      console.log('updated') if !err
      res.send(todo)

app.listen 3000