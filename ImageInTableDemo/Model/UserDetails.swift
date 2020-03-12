
import Foundation
struct  UserDetails : Codable {
	let title : String?
	let rows : [Rows]?

	enum CodingKeys: String, CodingKey {

		case title = "title"
		case rows = "rows"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		rows = try values.decodeIfPresent([Rows].self, forKey: .rows)
	}

}
