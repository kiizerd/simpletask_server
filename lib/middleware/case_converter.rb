require 'json'

module CaseConverter
  class Transformations
    class << self
      def transform(value)
        case value
          when Array then value.map { |item| transform(item) }
          when Hash then value.deep_transform_keys! { |key| transform(key) }
          when String then camelize(value)
          else value
        end
      end

      def camelize(string)
        string.underscore.camelize(:lower)
      end

      def underscore_params(env)
        req = ActionDispatch::Request.new(env)
        req.request_parameters
        req.query_parameters

        env['action_dispatch.request.request_parameters'].deep_transform_keys!(&:underscore)
        env['action_dispatch.request.query_parameters'].deep_transform_keys!(&:underscore)
      end
    end
  end

  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env) # rubocop:disable Metrics/MethodLength
      # Transform request
      Transformations.underscore_params(env)

      # Transform response
      status, headers, response = @app.call(env)

      new_responses = []

      response.each do |body|
        begin
          new_response = JSON.load(body)
        rescue JSON::ParserError
          new_responses << body
          next
        end

        Transformations.transform(new_response)

        new_responses << JSON.dump(new_response)
      end

      [status, headers, new_responses]
    end
  end
end
