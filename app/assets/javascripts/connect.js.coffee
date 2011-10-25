connecting = ->
  $("#connect a").css('opacity', 0.5).html('Connecting...')
  $('#indicator').css('opacity', 1)

window.initializeConnect = ->
  $('#connect a').bind('click', -> connecting())
  true