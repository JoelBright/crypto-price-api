module ProviderError
  class Error < StandardError; end

  class ConfigurationError < Error; end
  class UnsupportedSymbolError < Error; end
  class HttpError < Error; end
  class TimeoutError < Error; end
  class NetworkError < Error; end
  class ParseError < Error; end
  class MalformedResponseError < Error; end
end
