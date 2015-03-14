$(document).on 'click', '.delete-sentence', ->
  $(this).parent().parent().remove()

$(document).ready ->
  $('.add-sentence').click event, ->
    event.preventDefault()
    input = $('#sentence-to-add')
    if input.val()
      $('#sentences-table tr:last').after('<tr><td>' + input.val() + '</td><td>vlastná</td><td><a class="btn btn-danger delete-sentence">Zmaž vetu</a></td></tr>')
      input.val('')

  $('#sentences-submit').click ->
    sentences_ids = []

    for tablerow in $('#sentences-table tr')
      do (tablerow) ->
        sentences_ids.push $(tablerow).find('td:first').attr('sentence-id')

    $('#sentences-ids-list').attr('value', sentences_ids)
