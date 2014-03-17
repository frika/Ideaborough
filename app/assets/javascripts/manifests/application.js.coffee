#= require jquery.autosize
#= require jquery_ujs
#
#= require moment
#= require cloudinary
#
#= require exo
#= require_tree ../helpers
#= require_tree ../../templates
#= require ../config
#
#= require ../model
#= require ../collection
#= require_tree ../models
#= require_tree ../collections
#
#= require ../view
#= require_tree ../views
#
#= require_self

$ ->
  Backbone.history.root = "/"

  # Operator.currentUser = new Operator.Models.CurrentUser(currentUser, parse: true)
  Ideaborough.keyboardManager = new Exo.KeyboardManager()

  Ideaborough.application = new Ideaborough.Views.Application
    el: document.body
    keyboardManager: Ideaborough.keyboardManager

  Backbone.history.start
    root: "/"

  #-----------------------------------------------------------------------------
  # Global
  #-----------------------------------------------------------------------------

  $(document).on "click", "#flash-dismiss", (e) ->
    $("#flash").hide()
