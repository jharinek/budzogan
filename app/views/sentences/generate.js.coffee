<% @sentences.each_with_index do |sentence, i| %>
  $('#sentences-table tr:last').after('<tr><td sentence-id="<%= sentence.id %>"><%= sentence.content %></td><td><%= sentence.source %></td><td><%= link_to 'Zmaž vetu', '#', class: 'btn btn-danger delete-sentence' %></td></tr>')
<% end %>
