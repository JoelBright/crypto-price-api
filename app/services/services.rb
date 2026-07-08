module Services
  module_function

  def price_query
    PriceQueryService.new(
      repository: CryptoPriceRepository.new,
      cache: PriceCache.new
    )
  end

  def price_refresh
    PriceRefreshService.new(
      provider_client: CoinGeckoClient.new,
      repository: CryptoPriceRepository.new,
      cache: PriceCache.new
    )
  end
end
