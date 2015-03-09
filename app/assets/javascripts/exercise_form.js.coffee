radio_changed = ->
  $('.element input').attr('disabled', true)
  $('.element label').addClass('disabled')
  $('.group-title').addClass('disabled')

  elements = $('input:radio:checked').siblings('div')
  elements.find('.element input').attr('disabled', false)
  elements.find('.element label').removeClass('disabled')
  elements.find('.group-title').removeClass('disabled')

$(document).ready ->
  radio_changed()

  $("input:radio").change ->
    radio_changed()

  $('select.attribute-select').select2({
    placeholder: 'Vyberte jednu z možností'
  }).on 'change', ->
    if $('.select2-chosen').text() == 'Urobte kompletny rozbor vety'
      $('#exercise_elements_dragging').click()
