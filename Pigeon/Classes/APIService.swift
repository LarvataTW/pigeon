import Foundation

class APIService: NSObject {
  func registerDevice(_ device: Device, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error) -> Void) {

    guard let body = try? JSONSerialization.data(withJSONObject: device.body(), options: []) else { return }
    guard let appKey = device.appKey else { return }

    let urlString = stringURL(type: .device)
    guard let url = URL(string: urlString) else { return }

    var request = URLRequest(url: url)
    request.httpMethod = HttpMethod.POST.rawValue
    request.httpBody = body
    request.allHTTPHeaderFields = ["app_key": appKey]

    URLSession.shared.dataTask(with: request) { (data, response, error) in
      print("---------registerDevice--------------")
      print(data)
      print(response)
      print(error)
      print("----------------------------------------")

      if let err = error {
        errorHandler(err)
      } else if let resp = response {
        if self.validateStatusCode(resp),
           let data = data {
          completionHandler(data)
        } else {
          errorHandler(ServiceError.wrongParams)
        }
      } else {
        errorHandler(ServiceError.noResponse)
      }

    }.resume()
  }

  private func stringURL(type: Type) -> String {
    return API.base.rawValue + type.rawValue
  }

  private func validateStatusCode(_ response: URLResponse) -> Bool {
    guard let resp = response as? HTTPURLResponse else { return false }
    return resp.statusCode == 200
  }
}

enum ServiceError: Error {
  case noResponse
  case wrongParams
}
