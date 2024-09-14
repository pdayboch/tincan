class UnprocessableEntityError < StandardError
  attr_reader :errors

  def initialize(errors = {})
    @errors = format_errors(errors)
    super('Unprocessable Entity')
  end

  private

  def format_errors(errors)
    errors.to_hash.map do |field, messages|
      messages.map do |message|
        field_str = field.to_s.camelize(:lower)
        {
          field: field_str,
          message: "#{field_str} #{message}"
        }
      end
    end.flatten
  end
end
