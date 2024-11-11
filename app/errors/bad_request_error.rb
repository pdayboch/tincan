class BadRequestError < StandardError
  attr_reader :errors

  def initialize(errors = {})
    @errors = format_errors(errors)
    super('Bad Request')
  end

  private

  def format_errors(errors)
    errors.map do |field, messages|
      messages.map do |message|
        {
          field: field.to_s.camelize(:lower),
          message: message
        }
      end
    end.flatten
  end
end
