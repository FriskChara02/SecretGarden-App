//
//  PolicyContent.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 25/9/26.
//

// Static content model for legal/policy pages.

import Foundation

public struct PolicySection: Identifiable {
    public let id = UUID()
    public let heading: String
    public let bullets: [String]

    public init(heading: String, bullets: [String]) {
        self.heading = heading
        self.bullets = bullets
    }
}

public struct PolicyDocument {
    public let displayTitle: String
    public let documentTitle: String
    public let lastUpdatedLabel: String
    public let introParagraphs: [String]
    public let sections: [PolicySection]

    public init(
        displayTitle: String,
        documentTitle: String,
        lastUpdatedLabel: String,
        introParagraphs: [String],
        sections: [PolicySection]
    ) {
        self.displayTitle = displayTitle
        self.documentTitle = documentTitle
        self.lastUpdatedLabel = lastUpdatedLabel
        self.introParagraphs = introParagraphs
        self.sections = sections
    }
}

public enum PolicyKind: Hashable {
    case communityRules
    case privacyPolicy
    case termsOfService
}

public enum PolicyContent {

    public static let communityRules = PolicyDocument(
        displayTitle: "Quy định",
        documentTitle: "QUY ĐỊNH DÀNH CHO CỘNG ĐỒNG SECRET GARDEN",
        lastUpdatedLabel: "Cập nhật lần cuối: 07 / 08 / 2026",
        introParagraphs: [
            "Cảm ơn bạn đã đồng hành cùng Secret Garden. Dưới đây là bộ quy định chung của cộng đồng - mong bạn dành chút thời gian đọc qua để chúng ta cùng giữ một không gian đọc truyện lành mạnh, văn minh.",
            "Việc tiếp tục sử dụng Secret Garden đồng nghĩa với việc bạn đã đọc, hiểu và đồng ý với toàn bộ nội dung dưới đây."
        ],
        sections: [
            PolicySection(
                heading: "I. Tôn trọng lẫn nhau",
                bullets: [
                    "Giao tiếp lịch sự, không công kích cá nhân hay xúc phạm người khác dưới bất kỳ hình thức nào.",
                    "Không phân biệt đối xử vì chủng tộc, giới tính, tôn giáo, vùng miền hay bất kỳ đặc điểm cá nhân nào.",
                    "Không mỉa mai ngoại hình hay đời sống riêng tư của người khác, kể cả qua hình ảnh/meme.",
                    "Không đùa cợt quá đà gây khó chịu cho người khác hoặc phá rối không gian chung.",
                    "Không dùng ngôn từ thô tục, xúc phạm.",
                    "Tôn trọng sự đa dạng sở thích - không công kích thể loại truyện người khác yêu thích."
                ]
            ),
            PolicySection(
                heading: "II. Tôn trọng nhóm dịch",
                bullets: [
                    "Trân trọng công sức của các nhóm dịch đã chia sẻ bản dịch tới cộng đồng.",
                    "Không hối thúc, gây áp lực hay có thái độ thiếu tôn trọng với nhóm dịch.",
                    "Góp ý cần lịch sự, mang tính xây dựng.",
                    "Không so sánh hoặc quảng cáo bản dịch của nhóm khác trong không gian của 1 nhóm."
                ]
            ),
            PolicySection(
                heading: "III. Nội dung, tên hiển thị & Avatar",
                bullets: [
                    "Không đăng bình luận, hình ảnh, tên hiển thị hoặc avatar mang nội dung phản cảm, bạo lực, 18+/NSFW hoặc vi phạm pháp luật.",
                    "Không quấy rối, gạ gẫm, đe dọa hay xúc phạm người khác qua ngôn từ.",
                    "Không đăng nội dung spoil ảnh hưởng trải nghiệm người đọc khác.",
                    "Không mời gọi tham gia nhóm/kênh 18+ ngoài nền tảng.",
                    "Tránh bàn luận chính trị, tôn giáo hoặc chủ đề dễ gây tranh cãi.",
                    "Không spam văn bản/emoji/ký tự vô nghĩa gây loãng nội dung."
                ]
            ),
            PolicySection(
                heading: "IV. Không quảng cáo",
                bullets: [
                    "Không quảng cáo cho các bên/sản phẩm không liên quan tới Secret Garden.",
                    "Không giới thiệu bản dịch của nhóm nằm ngoài hệ sinh thái Secret Garden."
                ]
            ),
            PolicySection(
                heading: "V. Mạo danh & quyền riêng tư",
                bullets: [
                    "Nghiêm cấm mạo danh người khác dưới mọi hình thức.",
                    "Không sử dụng hình ảnh/thông tin cá nhân của người khác khi chưa được đồng ý.",
                    "Tôn trọng quyền riêng tư - không tự ý công khai thông tin cá nhân của người khác.",
                    "Cấm chỉnh sửa/bịa đặt nội dung liên quan tới hình ảnh, thông tin người khác nhằm bôi nhọ hoặc gây nhầm lẫn."
                ]
            ),
            PolicySection(
                heading: "VI. Tôn trọng đội ngũ quản trị",
                bullets: [
                    "Admin/Mod chịu trách nhiệm vận hành nền tảng - người dùng cần hợp tác khi được xử lý vi phạm.",
                    "Nếu chưa hài lòng với cách xử lý, có thể phản hồi qua kênh liên hệ chính thức của Secret Garden."
                ]
            ),
            PolicySection(
                heading: "VII. Hình thức xử lý vi phạm",
                bullets: [
                    "Tuỳ mức độ vi phạm: nhắc nhở, khoá tài khoản tạm thời (1–7 ngày), hoặc khoá vĩnh viễn kèm gỡ nội dung vi phạm.",
                    "Vi phạm lặp lại sẽ bị xử lý nghiêm khắc hơn.",
                    "Việc xử lý có thể được thực hiện không cần báo trước, dựa trên đánh giá của đội ngũ quản trị.",
                    "Với các trường hợp chưa được liệt kê cụ thể, Admin có quyền xem xét và quyết định phù hợp."
                ]
            ),
            PolicySection(
                heading: "VIII. Thay đổi quy định",
                bullets: [
                    "Secret Garden có quyền sửa đổi, bổ sung Quy định này bất kỳ lúc nào.",
                    "Thay đổi có hiệu lực ngay khi được cập nhật trong app, thời gian cập nhật cuối luôn được ghi rõ.",
                    "Tiếp tục sử dụng sau khi Quy định thay đổi đồng nghĩa với việc bạn chấp nhận thay đổi đó."
                ]
            )
        ]
    )

    public static func document(for kind: PolicyKind) -> PolicyDocument {
        switch kind {
        case .communityRules: return communityRules
        case .privacyPolicy: return privacyPolicy
        case .termsOfService: return termsOfService
        }
    }

    public static let termsOfService = PolicyDocument(
        displayTitle: "Điều khoản",
        documentTitle: "ĐIỀU KHOẢN DỊCH VỤ",
        lastUpdatedLabel: "Cập nhật lần cuối: 07 / 08 / 2026",
        introParagraphs: [
            "Cảm ơn bạn đã sử dụng Secret Garden. Khi truy cập, đăng ký tài khoản hoặc dùng bất kỳ tính năng nào của Secret Garden, bạn xác nhận đã đọc, hiểu và đồng ý với toàn bộ Điều khoản dưới đây - nếu không đồng ý, vui lòng ngừng sử dụng dịch vụ."
        ],
        sections: [
            PolicySection(heading: "1. Phạm vi áp dụng", bullets: [
                "Điều khoản áp dụng cho mọi người dùng truy cập, đăng ký và sử dụng Secret Garden.",
                "Dịch vụ vận hành theo nguyên tắc tự do trên internet quốc tế và pháp luật nơi đặt máy chủ, không nhắm riêng tới cá nhân hay tổ chức nào."
            ]),
            PolicySection(heading: "2. Thay đổi điều khoản", bullets: [
                "Secret Garden có quyền sửa đổi Điều khoản bất kỳ lúc nào, hiệu lực ngay khi cập nhật trong app.",
                "Tiếp tục sử dụng sau khi cập nhật đồng nghĩa với việc bạn chấp nhận thay đổi đó."
            ]),
            PolicySection(heading: "3. Độ tuổi sử dụng", bullets: [
                "Người dùng cần đủ 16 tuổi trở lên để sử dụng Secret Garden.",
                "Việc sử dụng dịch vụ đồng nghĩa với việc bạn xác nhận đáp ứng điều kiện độ tuổi này."
            ]),
            PolicySection(heading: "4. Tài khoản người dùng", bullets: [
                "Cần đăng ký/đăng nhập để dùng đầy đủ tính năng.",
                "Bạn chịu trách nhiệm bảo mật tài khoản của mình, không chia sẻ/mua bán/chuyển nhượng cho người khác.",
                "Tên hiển thị, avatar, thông tin tài khoản phải phù hợp tiêu chuẩn cộng đồng và pháp luật.",
                "Secret Garden có quyền chỉnh sửa, tạm khoá hoặc xoá tài khoản vi phạm Điều khoản/Quy định cộng đồng."
            ]),
            PolicySection(heading: "5. Nội dung người dùng đăng tải", bullets: [
                "Bạn chịu trách nhiệm pháp lý với nội dung mình đăng tải, Secret Garden không chịu trách nhiệm liên đới.",
                "Nghiêm cấm nội dung công kích cá nhân, phân biệt đối xử, khiêu dâm/18+, bạo lực, tục tĩu, bodyshaming.",
                "Secret Garden có quyền gỡ nội dung vi phạm và xử lý tài khoản liên quan không cần báo trước."
            ]),
            PolicySection(heading: "6. Bản quyền & miễn trừ trách nhiệm", bullets: [
                "Secret Garden không sở hữu bản quyền các tác phẩm được đăng tải - chỉ đóng vai trò nền tảng lưu trữ/hiển thị.",
                "Bản dịch thuộc về cá nhân/nhóm dịch - bên thứ ba đăng tải nội dung."
            ]),
            PolicySection(heading: "7. Gỡ nội dung & khiếu nại bản quyền", bullets: [
                "Secret Garden có quyền gỡ nội dung không phù hợp định hướng cộng đồng hoặc rủi ro pháp lý.",
                "Chủ sở hữu bản quyền cho rằng bị vi phạm vui lòng liên hệ email hỗ trợ kèm bằng chứng sở hữu và liên kết nội dung liên quan."
            ]),
            PolicySection(heading: "8. Liên kết bên thứ ba", bullets: [
                "Secret Garden không chịu trách nhiệm về nội dung/chính sách của các liên kết bên thứ ba xuất hiện trong app."
            ]),
            PolicySection(heading: "9. Giới hạn trách nhiệm", bullets: [
                "Secret Garden không chịu trách nhiệm thiệt hại trực tiếp/gián tiếp phát sinh từ việc sử dụng dịch vụ."
            ]),
            PolicySection(heading: "10. Xử lý vi phạm & chấm dứt dịch vụ", bullets: [
                "Secret Garden có quyền tạm dừng, hạn chế, chấm dứt tài khoản vi phạm mà không cần báo trước."
            ]),
            PolicySection(heading: "11. Liên hệ", bullets: [
                "Mọi thắc mắc liên quan tới Điều khoản, vui lòng liên hệ qua email hỗ trợ trong mục Chính sách bảo mật."
            ])
        ]
    )

    public static let privacyPolicy = PolicyDocument(
        displayTitle: "Chính sách bảo mật",
        documentTitle: "CHÍNH SÁCH BẢO MẬT",
        lastUpdatedLabel: "Cập nhật lần cuối: 07 / 08 / 2026",
        introParagraphs: [
            "Chính sách này mô tả cách Secret Garden thu thập, sử dụng và bảo vệ thông tin của bạn khi sử dụng dịch vụ."
        ],
        sections: [
            PolicySection(heading: "1. Thông tin được thu thập", bullets: [
                "Email, tên hiển thị và thông tin tài khoản khi đăng ký.",
                "Nội dung bạn đăng tải, bình luận hoặc tương tác.",
                "Dữ liệu kỹ thuật như địa chỉ IP, thiết bị, phiên bản app."
            ]),
            PolicySection(heading: "2. Mục đích sử dụng", bullets: [
                "Vận hành và duy trì dịch vụ.",
                "Quản lý tài khoản người dùng.",
                "Cải thiện trải nghiệm sử dụng.",
                "Ngăn chặn gian lận, vi phạm và rủi ro pháp lý."
            ]),
            PolicySection(heading: "3. Chia sẻ thông tin", bullets: [
                "Secret Garden không bán, cho thuê hoặc trao đổi thông tin cá nhân của người dùng."
            ]),
            PolicySection(heading: "4. Liên kết bên thứ ba", bullets: [
                "Secret Garden không chịu trách nhiệm với cách bên thứ ba thu thập/sử dụng dữ liệu người dùng qua các liên kết trong app."
            ]),
            PolicySection(heading: "5. Bảo mật thông tin", bullets: [
                "Áp dụng các biện pháp kỹ thuật hợp lý để bảo vệ dữ liệu, dù không hệ thống nào an toàn tuyệt đối."
            ]),
            PolicySection(heading: "6. Quyền của bạn", bullets: [
                "Xem, chỉnh sửa thông tin cá nhân.",
                "Yêu cầu xoá tài khoản và dữ liệu liên quan.",
                "Ngừng sử dụng dịch vụ bất cứ lúc nào."
            ]),
            PolicySection(heading: "7. Thay đổi chính sách", bullets: [
                "Chính sách có thể cập nhật theo thời gian, có hiệu lực ngay khi đăng tải trong app."
            ]),
            PolicySection(heading: "8. Liên hệ", bullets: [
                "Mọi thắc mắc về Chính sách bảo mật, vui lòng liên hệ qua email hỗ trợ trong ứng dụng."
            ])
        ]
    )
}
