module WeatherOracle::CryptoWeather {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use aptos_framework::timestamp;

    /// Struct representing weather data for a specific location.
    struct WeatherData has store, key {
        location: String,      // City or location name
        temperature: u64,      // Temperature in Celsius * 100 (to handle decimals)
        humidity: u64,         // Humidity percentage
        last_updated: u64,     // Timestamp of last update
    }

    /// Error codes
    const E_WEATHER_DATA_NOT_FOUND: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;

    /// Function to initialize weather data for a location.
    /// Only the oracle owner can call this function.
    public fun set_weather_data(
        oracle_owner: &signer,
        location: String,
        temperature: u64,
        humidity: u64
    ) acquires WeatherData {
        let current_time = timestamp::now_seconds();
        
        // Check if weather data already exists, update or create new
        if (exists<WeatherData>(signer::address_of(oracle_owner))) {
            let weather_data = borrow_global_mut<WeatherData>(signer::address_of(oracle_owner));
            weather_data.location = location;
            weather_data.temperature = temperature;
            weather_data.humidity = humidity;
            weather_data.last_updated = current_time;
        } else {
            let weather_data = WeatherData {
                location,
                temperature,
                humidity,
                last_updated: current_time,
            };
            move_to(oracle_owner, weather_data);
        };
    }

    /// Function to get weather data for a specific oracle.
    /// Anyone can call this function to read weather data.
    public fun get_weather_data(oracle_address: address): (String, u64, u64, u64) acquires WeatherData {
        assert!(exists<WeatherData>(oracle_address), E_WEATHER_DATA_NOT_FOUND);
        
        let weather_data = borrow_global<WeatherData>(oracle_address);
        (
            weather_data.location,
            weather_data.temperature,
            weather_data.humidity,
            weather_data.last_updated
        )
    }
}