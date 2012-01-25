(function() {
  var Todo, app, application_root, express, mongoose, path;

  application_root = __dirname;

  express = require("express");

  path = require("path");

  mongoose = require("mongoose");

  app = express.createServer();

  mongoose.connect('mongodb://localhost/todo-coffee');

  Todo = mongoose.model('Todo', new mongoose.Schema({
    text: String,
    done: Boolean,
    order: Number
  }));

  app.configure(function() {
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.router);
    app.use(express.static(path.join(application_root, "public")));
    app.use(express.errorHAndler({
      dumpExceptions: true,
      showStack: true
    }));
    app.set('views', path.join(application_root, "views"));
    return app.set('view_engine', 'jade');
  });

  app.get('api/todos', function(req, res) {
    return Todo.find(function(err, todos) {
      return res.send(todos);
    });
  });

  app.get('api/todos/:id', function(res, req) {
    return Todo.findById(req.params.id, function(err, todo) {
      todo.text = req.body.text;
      todo.done = req.body.done;
      todo.order = req.body.order;
      return todo.save(function(err) {
        if (!err) console.log('updated');
        return res.send(todo);
      });
    });
  });

  app.listen(3000);

}).call(this);
