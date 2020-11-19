import Foundation

struct VISCAInquiry<Response> {
	var payload: Data
	var parseResponse: (_ payload: Data) -> Response?
}
