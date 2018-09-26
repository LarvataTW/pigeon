import Foundation

class APIService: NSObject {
  func registerDevice(_ device: Device, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error) -> Void) {
    guard let body = try? JSONSerialization.data(withJSONObject: device.body(), options: []) else { return }
    guard let appKey = device.appKey else { return }

    let urlString = stringURL(type: .device)
    guard let url = URL(string: urlString) else { return }

    var request = jsonRequest(url: url)
    request.httpMethod = HttpMethod.POST.rawValue
    request.httpBody = body

    var header = request.allHTTPHeaderFields ?? [:]
    header["app_key"] = appKey
    request.allHTTPHeaderFields = header

    performTask(request, completionHandler: { (data) in
      completionHandler(data)
    }) { (error) in
      errorHandler(error)
    }
  }

  func patchDevice(_ device: Device, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error) -> Void) {
    guard let pigeonToken = device.pigeonToken else { return }

    let urlString = stringURL(type: .device) + "/\(pigeonToken)"
    guard let url = URL(string: urlString) else { return }

    var request = jsonRequest(url: url)
    request.httpMethod = HttpMethod.PATCH.rawValue
    if let deviceToken = device.deviceToken {
      let body = try? JSONSerialization.data(withJSONObject: ["device_token": deviceToken], options: [])
      request.httpBody = body
    }

    performTask(request, completionHandler: { (data) in
      completionHandler(data)
    }) { (error) in
      errorHandler(error)
    }
  }

  private func performTask(_ request: URLRequest, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error) -> Void) {
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      print("---------registerDevice--------------")
      print("response: \(response)")
      print("error: \(error)")
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

  private func jsonRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = ["Content-Type": ContentType.json.rawValue]
    return request
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
