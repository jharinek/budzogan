$(document).ready ->
  if($('#edit-task').length != 0)
    $("#save").parent().parent().on "ajax:before", ->
      saveResult('1');
      return false;
