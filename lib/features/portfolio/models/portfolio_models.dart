class ProjectScreenDetail {
  final String tag;
  final String title;
  final String desc;
  final String desc2;
  final String imagePath;

  ProjectScreenDetail({
    required this.tag,
    required this.title,
    required this.desc,
    required this.desc2,
    required this.imagePath,
  });
}

class ProjectModel {
  final String id;
  final String title;
  final List<String> tags;
  final String problemStatementTag;
  final String problemStatement;
  final String description;
  final List<String> features;
  final String mainImage;
  final String modalTitle;
  final String techStack;
  final String footer;
  final Map<String, String> tabs;
  final Map<String, ProjectScreenDetail> screens;

  ProjectModel({
    required this.id,
    required this.title,
    required this.tags,
    required this.problemStatementTag,
    required this.problemStatement,
    required this.description,
    required this.features,
    required this.mainImage,
    required this.modalTitle,
    required this.techStack,
    required this.footer,
    required this.tabs,
    required this.screens,
  });
}

class CircularSkill {
  final String name;
  final int level;
  final String label;
  final String color;

  CircularSkill({
    required this.name,
    required this.level,
    required this.label,
    required this.color,
  });
}

class ExperienceItem {
  final String id;
  final String role;
  final String company;
  final String duration;
  final String description;
  final List<String> responsibilities;

  ExperienceItem({
    required this.id,
    required this.role,
    required this.company,
    required this.duration,
    required this.description,
    required this.responsibilities,
  });
}

List<ProjectModel> getPortfolioProjects(String lang) {
  final isVi = lang == 'vi';

  return [
    ProjectModel(
      id: 'hottoys',
      title: 'Hot Toys Store E-commerce',
      tags: ['ASP.NET CORE', 'ORACLE DB', 'FULLSTACK WEB'],
      problemStatementTag: 'UX PROBLEM STATEMENT',
      problemStatement: isVi
          ? 'Nhà sưu tầm mô hình cao cấp yêu cầu thông tin tồn kho tức thời và bộ lọc danh mục tinh gọn. Giải pháp này ánh xạ trực tiếp cấu trúc cơ sở dữ liệu quan hệ vào các bộ điều khiển hàng tồn kho trực quan.'
          : 'High-end collectors require real-time inventory visibility and streamlined catalog navigation. This solution directly maps relational database models to intuitive inventory controllers.',
      description: isVi
          ? 'Một ứng dụng full-stack MVC tích hợp quy trình làm việc frontend Razor Pages tương tác với cơ sở dữ liệu bảo mật để kiểm soát hàng tồn kho sản phẩm.'
          : 'A full-stack MVC application integrating interactive Razor Pages frontend workflows with a secure database for comprehensive product inventory control.',
      features: isVi
          ? [
              'Danh mục sản phẩm tương tác với bộ lọc tìm kiếm đa tiêu chí',
              'Phân quyền truy cập dựa trên vai trò (RBAC) cho khách hàng và quản trị viên',
              'Bảng điều khiển quản trị trực quan hóa biểu đồ doanh thu và báo cáo bán hàng'
            ]
          : [
              'Interactive product catalog with multi-criteria dynamic search filtering',
              'Role-Based Access Control (RBAC) for customers and administrative staff',
              'Administrative dashboard visualizing revenue charts and sales analytics'
            ],
      mainImage: 'assets/images/hottoys_main.png',
      modalTitle: isVi ? 'Hot Toys Store — Giao diện hệ thống' : 'Hot Toys Store — System Interface',
      techStack: 'ASP.NET CORE MVC & ORACLE DB E-COMMERCE',
      footer: isVi
          ? 'THIẾT KẾ TRÊN FIGMA • KIẾN TRÚC HỆ THỐNG ASP.NET CORE MVC & ORACLE DB'
          : 'DESIGNED ON FIGMA • ASP.NET CORE MVC & ORACLE DB ARCHITECTURE',
      tabs: {
        'home': 'Home & Banner',
        'featured': 'Featured Products',
        'catalog': 'Catalog & Products',
        'stats': 'Statistics & Management',
      },
      screens: {
        'home': ProjectScreenDetail(
          tag: 'HOMEPAGE & HERO BANNER',
          title: isVi ? 'Chào mừng đến với ToyStore' : 'Welcome to ToyStore',
          desc: isVi
              ? 'Trang chủ sở hữu thiết kế tối giản, sang trọng và tối màu, tập trung cao độ vào việc làm nổi bật các mô hình nhân vật cao cấp.'
              : 'The homepage embraces a sleek, dark aesthetic emphasizing high-end collectible figures.',
          desc2: isVi
              ? 'Banner chính hiển thị hình ảnh độ tương phản cao với hiệu ứng chuyển tiếp mượt mà, tích hợp thanh tìm kiếm thông minh trực quan.'
              : 'High-contrast hero banners with smooth transitions and an intuitive centered search bar.',
          imagePath: 'assets/images/hottoys_screen_home.png',
        ),
        'featured': ProjectScreenDetail(
          tag: 'FEATURED PRODUCTS',
          title: isVi ? 'Phân phối theo Bộ sưu tập' : 'Distribution by Collection',
          desc: isVi
              ? 'Phân khu trưng bày các bộ sưu tập được tuyển chọn kỹ lượng như Anime (2B), DC (Superman) và Wukong.'
              : 'Curated showcase collections featuring Anime (2B), DC (Superman), and Wukong.',
          desc2: isVi
              ? 'Thiết kế thẻ Card UI sạch sẽ với các đường viền mềm mại.'
              : 'Clean Card UI design with soft borders highlighting available items.',
          imagePath: 'assets/images/hottoys_screen_featured.png',
        ),
        'catalog': ProjectScreenDetail(
          tag: 'CATALOG & PRODUCT DETAILS',
          title: isVi ? 'Mua sắm Tiện lợi & Đa dạng' : 'Convenient & Diverse Catalog',
          desc: isVi
              ? 'Phân loại sản phẩm thông minh theo vũ trụ điện ảnh hoặc thương hiệu sản xuất như DC, Marvel hoặc Anime.'
              : 'Intelligent product grouping by cinematic universe or franchise brand.',
          desc2: isVi
              ? 'Mỗi sản phẩm hiển thị thông số chi tiết, tình trạng kho hàng và giá bán.'
              : 'Detailed product specifications, real-time stock status, and domestic pricing.',
          imagePath: 'assets/images/hottoys_screen_catalog.png',
        ),
        'stats': ProjectScreenDetail(
          tag: 'REPORTS & ADMIN DASHBOARD',
          title: isVi ? 'Bảng phân tích Dữ liệu Chi tiết' : 'Detailed Data Analytics',
          desc: isVi
              ? 'Hệ thống tích hợp bảng điều khiển quản trị thông minh chuyên biệt dành cho các nhà quản lý để giám sát doanh thu.'
              : 'Dedicated management dashboard empowering operators to monitor revenue.',
          desc2: isVi
              ? 'Bao gồm các biểu đồ dữ liệu tương tác theo dõi doanh thu & lượng đơn hàng.'
              : 'Interactive chart visualizations tracking gross sales, orders, and user accounts.',
          imagePath: 'assets/images/hottoys_screen_dashboard.png',
        ),
      },
    ),
    ProjectModel(
      id: 'homme',
      title: 'HOMME Store',
      tags: ['ASP.NET CORE MVC', 'MS SQL SERVER', 'SIGNALR', 'RESTFUL API'],
      problemStatementTag: 'BACKEND ARCHITECTURE STATEMENT',
      problemStatement: isVi
          ? 'Xây dựng lõi xử lý e-commerce mạnh mẽ kết hợp tự động hóa vận chuyển logistics thực tế và tương tác khách hàng thời gian thực qua AI Chatbot và SignalR socket.'
          : 'Engineering a resilient e-commerce core combining real-world logistics shipping automation and real-time customer interaction via AI Chatbot and SignalR sockets.',
      description: isVi
          ? 'Hệ thống bán hàng e-commerce thời trang nam tối ưu hóa nghiệp vụ backend, tích hợp cổng chat hỗ trợ tư vấn thông minh và giải thuật tính toán phí giao hàng tự động.'
          : 'A menswear e-commerce platform with an optimized backend, intelligent customer support chat integration, and automated logistics shipping fee calculations.',
      features: isVi
          ? [
              'Tích hợp Chatbot AI và Live Chat thời gian thực với SignalR kết nối tức thời đến nhân viên hỗ trợ',
              'Tự động hóa quy trình giao nhận bằng cách tích hợp API Giao Hàng Nhanh (GHN)',
              'Bảo mật thông tin hệ thống với phân quyền 3 cấp (Admin, Employee, Customer)'
            ]
          : [
              'Integrated AI Chatbot and real-time Live Chat via SignalR instantly connecting shoppers with support agents',
              'Automated shipping calculation and bill generation through Giao Hang Nhanh (GHN) API integration',
              'Three-tier Role-Based Access Control (Admin, Employee, Customer) with secure session management'
            ],
      mainImage: 'assets/images/homme_main.jpg',
      modalTitle: isVi ? 'HOMME Store — Giao diện hệ thống' : 'HOMME Store — System Interface',
      techStack: 'ASP.NET CORE MVC & MS SQL SERVER PLATFORM',
      footer: isVi
          ? 'PHÁT TRIỂN HỆ THỐNG • CORE BACKEND ASP.NET CORE MVC & MS SQL SERVER'
          : 'SYSTEM DEVELOPMENT • ASP.NET CORE MVC & MS SQL SERVER CORE BACKEND',
      tabs: {
        'catalog': 'Catalog & Shipping',
        'vouchers': 'Marketing & Vouchers',
        'chat': 'AI Chat & Support',
      },
      screens: {
        'catalog': ProjectScreenDetail(
          tag: 'CATALOG & DYNAMIC FILTERS',
          title: isVi ? 'Trang Danh mục Sản phẩm & Bộ lọc Thông minh' : 'Product Catalog & Dynamic Filters',
          desc: isVi
              ? 'Giao diện bộ lọc bên trái trực quan cho phép phân loại nhanh theo khoảng giá (VND), danh mục thời trang và kích cỡ.'
              : 'Intuitive sidebar filters allowing multi-attribute filtering by price range, category, and sizing.',
          desc2: isVi
              ? 'Hệ thống tự động đồng bộ API Giao Hàng Nhanh (GHN) để tính phí vận chuyển chính xác.'
              : 'Automated integration with GHN logistics API for precise real-time shipping fee calculation.',
          imagePath: 'assets/images/homme_screen_catalog.jpg',
        ),
        'vouchers': ProjectScreenDetail(
          tag: 'ADMIN VOUCHER MANAGEMENT',
          title: isVi ? 'Trình Quản lý Mã Giảm giá & Khuyến mãi' : 'Voucher & Promotion Management',
          desc: isVi
              ? 'Bảng điều khiển quản trị chuyên sâu hỗ trợ phát hành voucher mới với đầy đủ thiết lập mã, hạn dùng, phần trăm.'
              : 'Administrative portal supporting promotional voucher generation with custom discounts and expiry dates.',
          desc2: isVi
              ? 'Hiển thị trạng thái kích hoạt thực tế và hủy hiệu lực tức thời.'
              : 'Live activation toggle enabling instant coupon status management.',
          imagePath: 'assets/images/homme_screen_vouchers.jpg',
        ),
        'chat': ProjectScreenDetail(
          tag: 'AI CHATBOT & SIGNALR LIVE SUPPORT',
          title: isVi ? 'Trung tâm Hỗ trợ Khách hàng Đa kênh' : 'Multi-Channel Customer Support',
          desc: isVi
              ? 'Cổng giao tiếp đa luồng tích hợp Chatbot AI tự động phản hồi các câu hỏi thường gặp của khách hàng.'
              : 'Integrated AI Chatbot automatically answering customer inquiries.',
          desc2: isVi
              ? 'Hệ thống kết nối SignalR Socket cho phép người mua chuyển đổi sang trò chuyện trực tuyến trực tiếp.'
              : 'SignalR socket infrastructure allowing seamless live handoff to human support staff.',
          imagePath: 'assets/images/homme_screen_chat.jpg',
        ),
      },
    ),
    ProjectModel(
      id: 'treasure',
      title: 'Treasure Hunter',
      tags: ['JAVA SE', 'TCP SOCKETS', 'MULTITHREADING', 'GAME ENGINE'],
      problemStatementTag: 'GAME MECHANICS STATEMENT',
      problemStatement: isVi
          ? 'Lập trình trò chơi đi cảnh đồng bộ thời gian thực cho nhiều người chơi qua socket, tối ưu hóa vòng lặp game loop đạt hiệu năng phản hồi tức thời không trễ.'
          : 'Developing a real-time multiplayer platformer with TCP sockets, optimizing game loops for zero-latency gameplay responsiveness.',
      description: isVi
          ? 'Trò chơi đi cảnh 2D Multiplayer viết trên nền tảng Java SE thuần, xây dựng máy chủ chuyên biệt và đồng bộ chuyển động, hoạt ảnh của người chơi qua mạng.'
          : 'A 2D multiplayer platformer developed in pure Java SE, featuring a custom dedicated server synchronizing player movements and animations.',
      features: isVi
          ? [
              'Vòng lặp game loop chuẩn công nghiệp tối ưu hóa hiệu năng: 200 UPS cập nhật vật lý và 120 FPS dựng hình',
              'Hệ thống máy chủ đa luồng sử dụng TCP Sockets đồng bộ hóa chuyển động thời gian thực',
              'Ứng dụng mẫu thiết kế OOP & State Pattern giúp module hóa mã nguồn'
            ]
          : [
              'Industry-standard game loop optimizing performance: 200 UPS physics updates and 120 FPS rendering',
              'Multithreaded server architecture utilizing TCP sockets for real-time synchronization',
              'OOP and State Pattern architecture enabling modular game extensions'
            ],
      mainImage: 'assets/images/treasure_main.jpg',
      modalTitle: isVi ? 'Treasure Hunter — Giao diện Game' : 'Treasure Hunter — Game Interface',
      techStack: 'JAVA SE & TCP SOCKET MULTIPLAYER ENGINE',
      footer: isVi
          ? 'PHÁT TRIỂN GAME • CORE GAME ENGINE JAVA SE & MULTITHREADING'
          : 'GAME DEVELOPMENT • JAVA SE & MULTITHREADED GAME ENGINE',
      tabs: {
        'lobby': 'Lobby & Setup',
        'gameplay': 'Core Gameplay',
        'victory': 'Victory & Completion',
      },
      screens: {
        'lobby': ProjectScreenDetail(
          tag: 'START MENU & CHARACTER CREATION',
          title: isVi ? 'Bảng điều khiển & Đăng ký Nhân vật' : 'Lobby & Character Setup',
          desc: isVi
              ? 'Màn hình bắt đầu của game được xây dựng trên bảng gỗ Pixel Art cổ điển nổi bật trên nền trời sao tím và trăng tròn.'
              : 'Classic pixel-art wooden board start menu set against a starry night sky backdrop.',
          desc2: isVi
              ? 'Hộp thoại đăng ký yêu cầu người chơi nhập biệt danh đại diện của mình (ví dụ: DUKA).'
              : 'Registration dialog prompting players to enter custom nicknames before joining rooms.',
          imagePath: 'assets/images/treasure_screen_lobby.jpg',
        ),
        'gameplay': ProjectScreenDetail(
          tag: '2D PLATFORMER MECHANICS',
          title: isVi ? 'Cơ chế Đi cảnh & Chiến đấu Đồng bộ' : 'Synchronized Platforming & Combat',
          desc: isVi
              ? 'Người chơi điều khiển nhân vật cướp biển nhảy tránh bẫy chông nhọn, thu thập hòm báu và chiến đấu cận chiến với quái vật cua.'
              : 'Players navigate pirate characters dodging spike traps, collecting chests, and combating crab monsters.',
          desc2: isVi
              ? 'Hiển thị thanh máu (HP) và thanh năng lượng trực quan ở góc trên bên trái màn hình.'
              : 'HUD displaying health (HP) and energy gauges in real time across clients.',
          imagePath: 'assets/images/treasure_screen_gameplay.jpg',
        ),
        'victory': ProjectScreenDetail(
          tag: 'LEVEL COMPLETED & PROGRESSION',
          title: isVi ? 'Giao diện Kết thúc Màn chơi' : 'Level Completed & Progression',
          desc: isVi
              ? 'Sau khi vượt qua toàn bộ thử thách và tiêu diệt quái vật, hệ thống hiển thị bảng gỗ chúc mừng LEVEL COMPLETED.'
              : 'Celebratory wooden panel rewarding players upon clearing platform challenges.',
          desc2: isVi
              ? 'Người chơi có thể nhanh chóng nhấn nút Home để quay lại sảnh chính hoặc nút Tiếp tục để chơi tiếp.'
              : 'Quick action buttons allowing players to return to the lobby or advance to the next level.',
          imagePath: 'assets/images/treasure_screen_victory.jpg',
        ),
      },
    ),
  ];
}
