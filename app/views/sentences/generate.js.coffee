  a = parseInt $('#sentences-table tr:last td:first').text(), 10

<% @sentences.each_with_index do |sentence, i| %>
  index = a + parseInt(<%= i+1 %>, 10)
  $('#sentences-table tr:last').after('<tr><td><%= sentence.content %></td><td>TODO</td><td><%= link_to 'Zmaž vetu', '#', class: 'btn btn-danger delete-sentence' %></td></tr>')
<% end %>
