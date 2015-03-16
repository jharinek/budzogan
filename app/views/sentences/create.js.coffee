$("td:contains('<%= @sentence.content %>')").attr('sentence-id', <%= @sentence.id %>)
