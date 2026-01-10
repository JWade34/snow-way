import { Controller } from "@hotwired/stimulus"

// Major US airports with coordinates
const AIRPORTS = [
  { code: "LAX", name: "Los Angeles", lat: 33.9425, lon: -118.4081 },
  { code: "SFO", name: "San Francisco", lat: 37.6213, lon: -122.3790 },
  { code: "DEN", name: "Denver", lat: 39.8561, lon: -104.6737 },
  { code: "SEA", name: "Seattle", lat: 47.4502, lon: -122.3088 },
  { code: "PHX", name: "Phoenix", lat: 33.4373, lon: -112.0078 },
  { code: "SLC", name: "Salt Lake City", lat: 40.7899, lon: -111.9791 },
  { code: "LAS", name: "Las Vegas", lat: 36.0840, lon: -115.1537 },
  { code: "PDX", name: "Portland", lat: 45.5898, lon: -122.5951 },
  { code: "SAN", name: "San Diego", lat: 32.7338, lon: -117.1933 },
  { code: "OAK", name: "Oakland", lat: 37.7126, lon: -122.2197 },
  { code: "SMF", name: "Sacramento", lat: 38.6954, lon: -121.5908 },
  { code: "SJC", name: "San Jose", lat: 37.3639, lon: -121.9289 },
  { code: "BOS", name: "Boston", lat: 42.3656, lon: -71.0096 },
  { code: "JFK", name: "New York JFK", lat: 40.6413, lon: -73.7781 },
  { code: "EWR", name: "Newark", lat: 40.6895, lon: -74.1745 },
  { code: "ORD", name: "Chicago", lat: 41.9742, lon: -87.9073 },
  { code: "DFW", name: "Dallas", lat: 32.8998, lon: -97.0403 },
  { code: "ATL", name: "Atlanta", lat: 33.6407, lon: -84.4277 },
  { code: "MIA", name: "Miami", lat: 25.7959, lon: -80.2870 },
  { code: "MSP", name: "Minneapolis", lat: 44.8848, lon: -93.2223 },
  { code: "DTW", name: "Detroit", lat: 42.2162, lon: -83.3554 },
  { code: "PHL", name: "Philadelphia", lat: 39.8744, lon: -75.2424 },
  { code: "IAD", name: "Washington DC", lat: 38.9531, lon: -77.4565 },
  { code: "CLT", name: "Charlotte", lat: 35.2140, lon: -80.9431 },
  { code: "AUS", name: "Austin", lat: 30.1975, lon: -97.6664 },
  { code: "YVR", name: "Vancouver", lat: 49.1967, lon: -123.1815 },
  { code: "YYC", name: "Calgary", lat: 51.1215, lon: -114.0076 },
  { code: "YEG", name: "Edmonton", lat: 53.3097, lon: -113.5792 }
]

export default class extends Controller {
  static targets = ["button", "status", "airportSelect"]
  static values = { detected: Boolean }

  connect() {
    this.loadSavedAirport()
  }

  loadSavedAirport() {
    const saved = localStorage.getItem("homeAirport")
    if (saved) {
      this.detectedValue = true
      this.updateUI(saved)
      this.updateFlightLinks(saved)
    }
  }

  detect() {
    if (!navigator.geolocation) {
      this.showStatus("Geolocation not supported", "error")
      return
    }

    this.showStatus("Detecting location...", "loading")

    navigator.geolocation.getCurrentPosition(
      (position) => this.handleSuccess(position),
      (error) => this.handleError(error),
      { enableHighAccuracy: false, timeout: 10000 }
    )
  }

  handleSuccess(position) {
    const { latitude, longitude } = position.coords
    const nearest = this.findNearestAirport(latitude, longitude)
    
    localStorage.setItem("homeAirport", nearest.code)
    this.detectedValue = true
    this.updateUI(nearest.code)
    this.updateFlightLinks(nearest.code)
    this.showStatus(`Set to ${nearest.name} (${nearest.code})`, "success")
  }

  handleError(error) {
    console.error("Geolocation error:", error)
    this.showStatus("Could not detect location. Select manually below.", "error")
  }

  findNearestAirport(lat, lon) {
    let nearest = AIRPORTS[0]
    let minDistance = this.haversineDistance(lat, lon, nearest.lat, nearest.lon)

    for (const airport of AIRPORTS) {
      const distance = this.haversineDistance(lat, lon, airport.lat, airport.lon)
      if (distance < minDistance) {
        minDistance = distance
        nearest = airport
      }
    }

    return nearest
  }

  haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 3959 // Earth's radius in miles
    const dLat = this.toRad(lat2 - lat1)
    const dLon = this.toRad(lon2 - lon1)
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLon/2) * Math.sin(dLon/2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  }

  toRad(deg) {
    return deg * (Math.PI / 180)
  }

  selectAirport(event) {
    const code = event.target.value
    if (code) {
      localStorage.setItem("homeAirport", code)
      this.detectedValue = true
      this.updateUI(code)
      this.updateFlightLinks(code)
      this.showStatus(`Home airport set to ${code}`, "success")
    }
  }

  updateUI(code) {
    if (this.hasAirportSelectTarget) {
      this.airportSelectTarget.value = code
    }
  }

  updateFlightLinks(originCode) {
    // Update all flight links on the page
    document.querySelectorAll('a[href*="google.com/travel/flights"]').forEach(link => {
      const url = new URL(link.href)
      // Google Flights URL format: flights to DEST from ORIGIN
      const currentSearch = url.searchParams.get('q') || ''
      const newSearch = currentSearch.replace(/from\+[A-Z]{3}/, `from+${originCode}`)
                                     .replace(/from [A-Z]{3}/, `from ${originCode}`)
      if (newSearch !== currentSearch) {
        url.searchParams.set('q', newSearch)
        link.href = url.toString()
      }
    })

    // Dispatch event for other components
    window.dispatchEvent(new CustomEvent('homeAirportChanged', { detail: { code: originCode } }))
  }

  showStatus(message, type) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.className = `text-sm mt-2 ${
        type === 'error' ? 'text-red-400' : 
        type === 'success' ? 'text-green-400' : 
        'text-slate-400'
      }`
    }
  }

  get airportOptions() {
    return AIRPORTS
  }
}
