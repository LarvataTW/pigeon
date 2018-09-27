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
    }, errorHandler: { (error) in
      errorHandler(error)
    })
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
    }, errorHandler: { (error) in
      errorHandler(error)
    })
  }

  private func performTask(_ request: URLRequest, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error) -> Void) {
    URLSession.shared.dataTask(with: request) { [unowned self] (data, response, error) in
        guard error == nil else {
          errorHandler(error!)
          return
        }

        guard let resp = response,
              let data = data
          else {
            errorHandler(PigeonServiceError(statusCode: unexpectedError))
            return
        }

        let code = self.statusCode(resp)
        guard code != unexpectedError else {
          errorHandler(PigeonServiceError(statusCode: unexpectedError))
          return
        }

        guard self.validateStatusCode(code) == true else {
          errorHandler(PigeonServiceError(statusCode: code))
          return
        }

        completionHandler(data)

    }.resume()
  }

  private func stringURL(type: Type) -> String {
    return API.base.rawValue + type.rawValue
  }

  private func jsonRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = ["Content-Type": ContentType.json.rawValue,
                                   "Accept": ContentType.json.rawValue]
    return request
  }

  private func statusCode(_ response: URLResponse) -> Int {
    guard let resp = response as? HTTPURLResponse else { return unexpectedError }
    return resp.statusCode
  }

  private func validateStatusCode(_ code: Int) -> Bool {
    return code == 200
  }
}
