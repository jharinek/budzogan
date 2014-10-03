$(document).ready ->
  $(".to-drag>input[id^='exercise_element_ids_']").attr(disabled: true)
  $(".prepared>input[id^='exercise_element_ids_']").attr(disabled: true)

  $(".to-drag>label[for^='exercise_element_ids_']").css('color', 'lightgray')
  $(".prepared>label[for^='exercise_element_ids_']").css('color', 'lightgray')

  $("input:radio").change ->
    if this.id == 'exercise_elements_dragging'
      $(".prepared>input[id^='exercise_element_ids_']").attr(disabled: true, checked: false)
      $(".to-drag>input[id^='exercise_element_ids_']").attr('disabled', false)

      $(".to-drag>label[for^='exercise_element_ids_']").css('color', 'black')
      $(".prepared>label[for^='exercise_element_ids_']").css('color', 'lightgray')
    else
      $(".prepared>input[id^='exercise_element_ids_']").attr('disabled', false)
      $(".to-drag>input[id^='exercise_element_ids_']").attr(disabled: true, checked: false)

      $(".to-drag>label[for^='exercise_element_ids_']").css('color', 'lightgray')
      $(".prepared>label[for^='exercise_element_ids_']").css('color', 'black')


  if $('.select2-chosen').text() == 'Urobte kompletny rozbor vety'
    $('#exercise_elements_dragging').click()

  $('select').select2({ width: 'resolve' }).on 'change', ->
    if $('.select2-chosen').text() == 'Urobte kompletny rozbor vety'
      $('#exercise_elements_dragging').click()
