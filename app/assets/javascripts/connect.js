function connecting() {
  $("#connect a").hide();
  $('#indicator').show();
}

window.initializeConnect = function() {
  $('#connect a').bind('click', connecting);
  return true;
}
