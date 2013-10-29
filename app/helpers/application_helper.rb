module ApplicationHelper
  def flash_class(level)
    case level
      when :notice then "info"
      when :error then "error"
      when :alert then "warning"
      else ""
    end
  end

  def placeholder_for_blank(data)
    return "-" if data.blank?
    data
  end

  def comma_seperated_string_to_array(string)
    string.split(",").map {|e| e.strip}
  end

  def boolean_mapper(value)
    value ? "Yes" : "No"
  end
  
  class BraintreeFormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TagHelper

    def initialize(object_name, object, template, options)
      super
      @braintree_params = @options[:params]
      @braintree_errors = @options[:errors]
    end

    def fields_for(record_name, *args, &block)
      options = args.extract_options!
      options[:builder] = BraintreeFormBuilder
      options[:params] = @braintree_params && @braintree_params[record_name]
      options[:errors] = @braintree_errors && @braintree_errors.for(record_name)
      new_args = args + [options]
      super record_name, *new_args, &block
    end

    def text_field(method, options = {})
      has_errors = @braintree_errors && @braintree_errors.on(method).any?
      field = super(method, options.merge(:value => determine_value(method)))
      result = content_tag("div", field, :class => has_errors ? "fieldWithErrors" : "")
      result.safe_concat validation_errors(method)
      result
    end

    protected

    def determine_value(method)
      @braintree_params[method] if @braintree_params
    end

    def validation_errors(method)
      if @braintree_errors && @braintree_errors.on(method).any?
        @braintree_errors.on(method).map do |error|
          content_tag("div", ERB::Util.h(error.message), {:style => "color: red;"})
        end.join
      else
        ""
      end
    end
  end
end
