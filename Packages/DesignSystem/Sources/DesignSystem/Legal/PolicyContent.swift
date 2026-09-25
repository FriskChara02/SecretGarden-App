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

public enum PolicyContent {

    public static let communityRules = PolicyDocument(
        displayTitle: "Quy định",
        documentTitle: "QUY ĐỊNH DÀNH CHO CỘNG ĐỒNG SECRET GARDEN",
        lastUpdatedLabel: "Cập nhật lần cuối: 07 / 08 / 2026",
        introParagraphs: [
            "Cảm ơn bạn đã đồng hành cùng Secret Garden. Dưới đây là bộ quy định chung của cộng đồng — mong bạn dành chút thời gian đọc qua để chúng ta cùng giữ một không gian đọc truyện lành mạnh, văn minh.",
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
                    "Tôn trọng sự đa dạng sở thích — không công kích thể loại truyện người khác yêu thích."
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
                    "Tôn trọng quyền riêng tư — không tự ý công khai thông tin cá nhân của người khác.",
                    "Cấm chỉnh sửa/bịa đặt nội dung liên quan tới hình ảnh, thông tin người khác nhằm bôi nhọ hoặc gây nhầm lẫn."
                ]
            ),
            PolicySection(
                heading: "VI. Tôn trọng đội ngũ quản trị",
                bullets: [
                    "Admin/Mod chịu trách nhiệm vận hành nền tảng — người dùng cần hợp tác khi được xử lý vi phạm.",
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
}
