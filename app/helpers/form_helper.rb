module FormHelper
  def form_messages(flash: self.flash, key: nil, resource: nil, context: form_messages_context)
    flash = flash[:form] || {}
    key   = (key || :global).to_sym
    store = flash[key].to_a

    if resource && key == context[:key].to_sym
      resource.errors.full_messages.reject(&:blank?).each { |message| store << [:error, message] }
    end

    render context[:partial], messages: store
  end

  def form_messages_context
    { key: (params[:tab] || :global).to_sym, partial: 'shared/form_messages' }
  end

  def form_messages_for(resource, options = {})
    form_messages(resource: resource, **options)
  end
end