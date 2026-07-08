class ErrorResponseSerializer
  MESSAGES = {
    invalid_symbol: "The symbol must contain only letters and be between 2 and 10 characters long.",
    unsupported_symbol: "The symbol '%<symbol>s' is not supported by this API.",
    price_not_found: "No stored price is available for symbol '%<symbol>s'.",
    internal_error: "An unexpected error occurred while processing the request."
  }.freeze

  def initialize(code:, symbol: nil)
    @code = code.to_sym
    @symbol = symbol
  end

  def as_json(*)
    {
      error: {
        code: code.to_s,
        message: message
      }
    }
  end

  private

  attr_reader :code, :symbol

  def message
    format(MESSAGES.fetch(code), symbol: symbol)
  end
end
