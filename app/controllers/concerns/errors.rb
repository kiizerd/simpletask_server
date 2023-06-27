# frozen_string_literal: true

# Provides unified methods for working with errors across resources.
module Errors
  extend ActiveSupport::Concern

  def formatted_errors(resource)
    return errors_for_nil_resource if resource.nil?

    errors = resource.errors
    details = errors.details
    messages = details.keys.index_with { |m| errors.full_messages_for(m) }

    { code: determine_error_code(resource), messages:, details: }
  end

  def determine_error_code(resource)
    errors = resource.errors
    if resource.class.attribute_names.any? { |n| errors.include?(n) }
      'invalid_parameters'
    else
      'unknown_error'
    end
  end

  def errors_for_nil_resource
    if @current_user
      { code: 'record not found' }
    else
      { code: 'authentication failed' }
    end
  end
end
