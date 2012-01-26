application_root = __dirname
express = require "express"
path = require "path"
mongoose = require "mongoose"

app = express.createServer()

mongoose.connect 'mongodb://localhost/test'

Todo = mongoose.model 'Todo', new mongoose.Schema({
  text: String,
  done: Boolean,
  order: Number
})

app.configure ->
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.static(path.join(application_root, "public")))
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true}))
  app.set('views', path.join(application_root, "views"))
  app.set('view engine', 'jade')


app.get '/', (req, res) ->
  res.send('Hello World')


app.get '/todo', (req, res) ->
  res.render('todo', {title: "MongoDB Backed TODO App"})

app.get '/api/todos', (req, res) ->
  Todo.find (err, todos) ->
    res.send(todos)

app.get '/api/todos/:id', (res, req) ->
  Todo.findById req.params.id, (err, todo) ->
    todo.text = req.body.text
    todo.done = req.body.done
    todo.order = req.body.order
    todo.save (err) ->
      console.log('updated') if !err
      res.send(todo)

app.put '/api/todos/:id', (req, res) ->
  Todo.findById req.params.id, (err, todo) ->
    todo.text = req.body.text
    todo.done = req.body.done
    todo.order = req.body.order
    todo.save (err) ->
      console.log("updated") if !err
      res.send(todo)

app.post '/api/todos', (req, res) ->
  todo = new Todo
    text: req.body.text
    done: req.body.done
    order: req.body.order
  todo.save (err) ->
    return console.log("updated") if !err
    res.send(todo)

app.delete '/api/todos/:id', (req, res) ->
  Todo.findById req.params.id, (err, todo) ->
    if !err
      todo.remove (err) ->
       console.log("removed") if !err
    return res.send('')

app.listen 3000