$(document).on 'click', '.delete-sentence', ->
  $(this).parent().parent().remove()

$(document).ready ->
  $('.add-sentence').click event, ->
    event.preventDefault()
    input = $('#sentence-to-add')
    if input.val()
      $('#sentences-table tr:last').after('<tr><td>' + input.val() + '</td><td>vlastná</td><td><a class="btn btn-danger delete-sentence">Zmaž vetu</a></td></tr>')
      input.val('')
