module EventSourcing
  class PublishService
    include ::Services::Callable

    receive :event_type, :payload, :stream_name

    ALLOWED_EVENTS = {
      home_page_viewed: 'HomePageViewed',
      post_viewed: 'PostViewed'
    }.freeze

    def result
      event = event_klass.new(data: @payload)
      event_store.publish(event, stream_name: @stream_name || 'all')
    end

    private

    def event_klass
      prefix = 'EventSourcing::Events'
      suffix = ALLOWED_EVENTS[@event_type.to_sym]

      "::#{prefix}::#{suffix}".constantize
    end

    def event_store
      Rails.configuration.event_store
    end
  end
end
