import Foundation

class APIService: NSObject {
  func registerDevice(_ device: Device, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (PigeonServiceError) -> Void) {
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

  func patchDevice(_ device: Device, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (PigeonServiceError) -> Void) {
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

  private func performTask(_ request: URLRequest, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (PigeonServiceError) -> Void) {

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
          errorHandler(PigeonServiceError.networkFail(error!))
          return
        }

        guard let httpResponse = response as? HTTPURLResponse,
              let data = data
          else {
            errorHandler(PigeonServiceError.unexpectedError(NSError(domain: NSURLErrorDomain,
                                                                    code: StatusCodeType.unexpectedError.rawValue,
                                                                    userInfo: nil)))
            return
        }

        do {
          try Validation.validateResponse(httpResponse)
          completionHandler(data)
        } catch let serviceError as PigeonServiceError {
          errorHandler(serviceError)
        } catch {
          // won't entry here
        }
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
}
