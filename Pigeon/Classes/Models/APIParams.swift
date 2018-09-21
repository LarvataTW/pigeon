import UIKit

enum HttpMethod: String {
  case POST = "POST"
  case GET = "GET"
  case PATCH = "PATCH"
}

enum API: String {
  case base = "https://virtserver.swaggerhub.com/larvata5/larvataPigeon/1.0.0"
}

enum Type: String {
  case device = "/api/device"
}
