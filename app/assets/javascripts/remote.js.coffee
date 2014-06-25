# TODO (jharinek) change this request call

$(document).ready ->
  $("#save").parent().parent().on "ajax:before", ->
    saveResult();
    return false;
