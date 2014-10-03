  a = parseInt $('#sentences-table tr:last td:first').text(), 10

<% @sentences.each_with_index do |sentence, i| %>
  index = a + parseInt(<%= i+1 %>, 10)
  $('#sentences-table tr:last').after('<tr><td>'+index+'</td><td><%= sentence.content %></td><td>sentence.source</td><td>actions</td></tr>')
<% end %>
