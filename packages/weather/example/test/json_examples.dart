Map<String, dynamic> weatherJsonExample() {
  return {
    "coord": {"lon": 12.58, "lat": 55.67},
    "weather": [
      {"id": 500, "main": "Rain", "description": "light rain", "icon": "10d"},
      {"id": 701, "main": "Mist", "description": "mist", "icon": "50d"}
    ],
    "base": "stations",
    "main": {
      "temp": 275.13,
      "pressure": 1017,
      "humidity": 99,
      "temp_min": 274.15,
      "temp_max": 276.15
    },
    "visibility": 10000,
    "wind": {"speed": 11.3, "deg": 170},
    "clouds": {"all": 90},
    "dt": 1543488600,
    "sys": {
      "type": 1,
      "id": 1575,
      "message": 0.0044,
      "country": "DK",
      "sunrise": 1543475502,
      "sunset": 1543502646
    },
    "id": 2618424,
    "name": "Københavns Kommune",
    "cod": 200
  };
}

Map<String, dynamic> forecastJsonExample() {
  return {
    "cod": "200",
    "message": 0.0034,
    "cnt": 10,
    "list": [
      {
        "dt": 1543492800,
        "main": {
          "temp": 276.18,
          "temp_min": 276.18,
          "temp_max": 277.685,
          "pressure": 1027.95,
          "sea_level": 1030.18,
          "grnd_level": 1027.95,
          "humidity": 99,
          "temp_kf": -1.5
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10d"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 12.21, "deg": 177.509},
        "rain": {"3h": 0.49},
        "sys": {"pod": "d"},
        "dt_txt": "2018-11-29 12:00:00"
      },
      {
        "dt": 1543503600,
        "main": {
          "temp": 276.6,
          "temp_min": 276.6,
          "temp_max": 277.73,
          "pressure": 1026.61,
          "sea_level": 1028.85,
          "grnd_level": 1026.61,
          "humidity": 100,
          "temp_kf": -1.13
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 11.29, "deg": 176.502},
        "rain": {"3h": 0.8375},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-29 15:00:00"
      },
      {
        "dt": 1543514400,
        "main": {
          "temp": 277.66,
          "temp_min": 277.66,
          "temp_max": 278.415,
          "pressure": 1025.41,
          "sea_level": 1027.6,
          "grnd_level": 1025.41,
          "humidity": 97,
          "temp_kf": -0.75
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 11.21, "deg": 175},
        "rain": {"3h": 1.2475},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-29 18:00:00"
      },
      {
        "dt": 1543525200,
        "main": {
          "temp": 277.98,
          "temp_min": 277.98,
          "temp_max": 278.359,
          "pressure": 1024.2,
          "sea_level": 1026.42,
          "grnd_level": 1024.2,
          "humidity": 98,
          "temp_kf": -0.38
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 11.51, "deg": 173.501},
        "rain": {"3h": 1.0475},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-29 21:00:00"
      },
      {
        "dt": 1543536000,
        "main": {
          "temp": 278.119,
          "temp_min": 278.119,
          "temp_max": 278.119,
          "pressure": 1023.17,
          "sea_level": 1025.44,
          "grnd_level": 1023.17,
          "humidity": 100,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 100},
        "wind": {"speed": 11.11, "deg": 177.501},
        "rain": {"3h": 2.1475},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-30 00:00:00"
      },
      {
        "dt": 1543546800,
        "main": {
          "temp": 278.547,
          "temp_min": 278.547,
          "temp_max": 278.547,
          "pressure": 1022.19,
          "sea_level": 1024.42,
          "grnd_level": 1022.19,
          "humidity": 98,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 88},
        "wind": {"speed": 10.36, "deg": 180.502},
        "rain": {"3h": 0.66},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-30 03:00:00"
      },
      {
        "dt": 1543557600,
        "main": {
          "temp": 278.509,
          "temp_min": 278.509,
          "temp_max": 278.509,
          "pressure": 1021.51,
          "sea_level": 1023.8,
          "grnd_level": 1021.51,
          "humidity": 100,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 100},
        "wind": {"speed": 10.45, "deg": 180.504},
        "rain": {"3h": 0.4475},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-30 06:00:00"
      },
      {
        "dt": 1543568400,
        "main": {
          "temp": 279.089,
          "temp_min": 279.089,
          "temp_max": 279.089,
          "pressure": 1021.38,
          "sea_level": 1023.67,
          "grnd_level": 1021.38,
          "humidity": 98,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10d"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 9.86, "deg": 180.504},
        "rain": {"3h": 0.175},
        "sys": {"pod": "d"},
        "dt_txt": "2018-11-30 09:00:00"
      },
      {
        "dt": 1543579200,
        "main": {
          "temp": 279.433,
          "temp_min": 279.433,
          "temp_max": 279.433,
          "pressure": 1021.23,
          "sea_level": 1023.38,
          "grnd_level": 1021.23,
          "humidity": 99,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10d"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 9.46, "deg": 185.5},
        "rain": {"3h": 0.975},
        "sys": {"pod": "d"},
        "dt_txt": "2018-11-30 12:00:00"
      },
      {
        "dt": 1543590000,
        "main": {
          "temp": 280.017,
          "temp_min": 280.017,
          "temp_max": 280.017,
          "pressure": 1021.06,
          "sea_level": 1023.32,
          "grnd_level": 1021.06,
          "humidity": 97,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10n"
          }
        ],
        "clouds": {"all": 92},
        "wind": {"speed": 8.52, "deg": 185.006},
        "rain": {"3h": 0.25},
        "sys": {"pod": "n"},
        "dt_txt": "2018-11-30 15:00:00"
      }
    ],
    "city": {
      "id": 2618424,
      "name": "Københavns Kommune",
      "coord": {"lat": 55.6667, "lon": 12.5833},
      "country": "DK"
    }
  };
}
