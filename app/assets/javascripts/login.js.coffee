checkPlaceholder = (input) ->
  if $(input).val() ==  ""
    $(input).siblings('label').show()
  else
    removePlaceholder(input)

checkPlaceholderForAllInputs = ->
  checkPlaceholder input for input in $('input')

removePlaceholder = (input) -> $(input).siblings('label').hide()

loginFormSubmission = (form) ->
  ajaxOptions =
    type: 'POST'
    url: form.attr('action')
    data: form.serializeArray()
    dataType: 'json'
    success: (data) ->
      handleLoginResponse data
    failure: (data) ->
      displayFlashNotice("An unexpected error occured. Please try again.")
      enableForm()
      
  $.ajax ajaxOptions  
  disableForm()
  $("#indicator").css 'opacity', 1.0
  false
  
disableForm = -> 
  $("input").attr('disabled', 'disabled').css('opacity', 0.5)

enableForm = ->
  $("input").removeAttr('disabled').css('opacity', 1.0)
  $("input#email").focus()
  
  
displayFlashNotice = (message) ->
  element = $("<div id='flash_notice' style='display: none'/>")
  element.html(message)
  $("#flash_notice_container").html(element)
  $("#flash_notice").show()
  
handleLoginResponse = (response) ->
  if response.status == "wrong_credentials"
    displayFlashNotice "Incorrect username or password"
    $("#login_panel form").effect('bounce', {direction: 'right', mode: 'effect', times: 3, distance: 10}, 'fast')
    $("#indicator").css('opacity', 0)
    enableForm()
    # Empty password field
    $("input#password").val('')
  else
    if response.status=="success"
      $("input").remove()
      $("#indicator").css('padding-left', '215px').css('position', 'relative')
      displayFlashNotice("Login successful, redirecting...")
      document.location = '/'
    else
      displayFlashNotice("An unexpected error occured. Please try again.")
      enableForm()

window.initializeLoginForm = ->
  checkPlaceholderForAllInputs()
  
  # To make sure it happens after the browser auto-fills login & password info
  setTimeout checkPlaceholderForAllInputs, 500

  # Initial focus on the email field
  $("input#email").focus()

  # Monitor for interaction on the fields to toggle the label place holder
  $('input').bind('keyup change blur focus', -> checkPlaceholder(this))
  $('input').bind('keydown', -> removePlaceholder(this))
  
  # Ajaxify the form
  $("#login_panel form").submit(-> loginFormSubmission($(this)))
  
  true