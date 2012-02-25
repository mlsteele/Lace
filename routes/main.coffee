module.exports = (app) ->
  app.get '/', (req, res) ->
    res.render 'index', {title: 'Lace', subtitle: 'Chat visualization experiment.'}
