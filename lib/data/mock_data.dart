import 'package:latlong2/latlong.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/chat_message_model.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

class MockData {
  MockData._();

  // ============ USERS ============
  static final List<UserModel> users = [
    UserModel(
      id: 'user_1',
      name: 'Made Naradeon',
      email: 'naradeon@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Suka makan pedas dan eksplor tempat makan baru 🌶️',
      foodPreferences: ['Pedas', 'Sunda', 'Seafood'],
      rating: 4.8,
      totalSessions: 15,
      sessionsCreated: 8,
      sessionsJoined: 7,
      createdAt: DateTime(2025, 1, 15),
    ),
    UserModel(
      id: 'user_2',
      name: 'Revandi Akbar',
      email: 'revandi@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Foodie sejati, makan adalah seni 🍜',
      foodPreferences: ['Jepang', 'Korea', 'Western'],
      rating: 4.5,
      totalSessions: 12,
      sessionsCreated: 5,
      sessionsJoined: 7,
      createdAt: DateTime(2025, 2, 1),
    ),
    UserModel(
      id: 'user_3',
      name: 'Naemu Enggar',
      email: 'naemu@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Vegetarian friendly, tapi suka coba semuanya ✌️',
      foodPreferences: ['Vegetarian', 'Salad', 'Jus'],
      rating: 4.7,
      totalSessions: 10,
      sessionsCreated: 4,
      sessionsJoined: 6,
      createdAt: DateTime(2025, 2, 10),
    ),
    UserModel(
      id: 'user_4',
      name: 'Muhammad Ihsan',
      email: 'ihsan@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Coffee addict ☕ & nasi goreng enthusiast',
      foodPreferences: ['Nasi Goreng', 'Coffee', 'Bakso'],
      rating: 4.3,
      totalSessions: 8,
      sessionsCreated: 3,
      sessionsJoined: 5,
      createdAt: DateTime(2025, 3, 5),
    ),
    UserModel(
      id: 'user_5',
      name: 'Saladin Setyo',
      email: 'saladin@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Anak kos yang suka patungan makan 💰',
      foodPreferences: ['Warteg', 'Padang', 'Ayam Geprek'],
      rating: 4.6,
      totalSessions: 20,
      sessionsCreated: 10,
      sessionsJoined: 10,
      createdAt: DateTime(2025, 1, 20),
    ),
  ];

  // ============ RESTAURANTS ============
  // Area Telkom University Bandung
  static final List<RestaurantModel> restaurants = [
    RestaurantModel(
      id: 'resto_1',
      name: 'Warung Nasi Ampera',
      address: 'Jl. Telekomunikasi No. 1, Bandung',
      location: const LatLng(-6.9732, 107.6310),
      rating: 4.5,
      category: 'Sunda',
      priceRange: 'Rp 15.000 - 30.000',
    ),
    RestaurantModel(
      id: 'resto_2',
      name: 'Kedai Kopi Nongkrong',
      address: 'Jl. Sukapura No. 12, Dayeuhkolot',
      location: const LatLng(-6.9750, 107.6325),
      rating: 4.3,
      category: 'Coffee & Snack',
      priceRange: 'Rp 20.000 - 45.000',
    ),
    RestaurantModel(
      id: 'resto_3',
      name: 'Ayam Geprek Juara',
      address: 'Jl. PGA No. 34, Bandung',
      location: const LatLng(-6.9715, 107.6290),
      rating: 4.7,
      category: 'Ayam Geprek',
      priceRange: 'Rp 12.000 - 25.000',
    ),
    RestaurantModel(
      id: 'resto_4',
      name: 'Mie Gacoan',
      address: 'Jl. Bojongsoang No. 88, Bandung',
      location: const LatLng(-6.9768, 107.6340),
      rating: 4.4,
      category: 'Mie Pedas',
      priceRange: 'Rp 10.000 - 20.000',
    ),
    RestaurantModel(
      id: 'resto_5',
      name: 'Bakso Boedjangan',
      address: 'Jl. Telekomunikasi No. 50, Bandung',
      location: const LatLng(-6.9720, 107.6355),
      rating: 4.6,
      category: 'Bakso',
      priceRange: 'Rp 18.000 - 35.000',
    ),
    RestaurantModel(
      id: 'resto_6',
      name: 'Sushi Tei Express',
      address: 'Jl. Buah Batu No. 15, Bandung',
      location: const LatLng(-6.9700, 107.6280),
      rating: 4.2,
      category: 'Jepang',
      priceRange: 'Rp 30.000 - 60.000',
    ),
    RestaurantModel(
      id: 'resto_7',
      name: 'Nasi Padang Sederhana',
      address: 'Jl. Sukapura No. 5, Dayeuhkolot',
      location: const LatLng(-6.9745, 107.6300),
      rating: 4.8,
      category: 'Padang',
      priceRange: 'Rp 15.000 - 30.000',
    ),
  ];

  // ============ SESSIONS ============
  static final List<SessionModel> sessions = [
    SessionModel(
      id: 'session_1',
      creatorId: 'user_1',
      creatorName: 'Made Naradeon',
      title: 'Makan Siang Bareng di Ampera 🍛',
      description:
          'Yuk makan siang bareng di Warung Ampera! Bisa sambil ngobrol tugas kelompok.',
      restaurantName: 'Warung Nasi Ampera',
      restaurantAddress: 'Jl. Telekomunikasi No. 1',
      location: const LatLng(-6.9732, 107.6310),
      startTime: DateTime.now().add(const Duration(hours: 2)),
      maxParticipants: 4,
      participantIds: ['user_1', 'user_2'],
      status: SessionStatus.open,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      category: 'Sunda',
    ),
    SessionModel(
      id: 'session_2',
      creatorId: 'user_5',
      creatorName: 'Saladin Setyo',
      title: 'Ngopi Sore ☕',
      description:
          'Butuh teman ngopi sore sambil ngerjain tugas. Yang mau join silakan!',
      restaurantName: 'Kedai Kopi Nongkrong',
      restaurantAddress: 'Jl. Sukapura No. 12',
      location: const LatLng(-6.9750, 107.6325),
      startTime: DateTime.now().add(const Duration(hours: 4)),
      maxParticipants: 3,
      participantIds: ['user_5'],
      status: SessionStatus.open,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      category: 'Coffee & Snack',
    ),
    SessionModel(
      id: 'session_3',
      creatorId: 'user_3',
      creatorName: 'Naemu Enggar',
      title: 'Geprek Time! 🔥',
      description:
          'Makan geprek level 5 nih, ada yang berani? Patungan aja biar hemat.',
      restaurantName: 'Ayam Geprek Juara',
      restaurantAddress: 'Jl. PGA No. 34',
      location: const LatLng(-6.9715, 107.6290),
      startTime: DateTime.now().add(const Duration(hours: 1)),
      maxParticipants: 5,
      participantIds: ['user_3', 'user_4', 'user_2'],
      status: SessionStatus.open,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Ayam Geprek',
    ),
    SessionModel(
      id: 'session_4',
      creatorId: 'user_2',
      creatorName: 'Revandi Akbar',
      title: 'Bakso Kuah Hangat 🍜',
      description: 'Hujan-hujan enaknya makan bakso!',
      restaurantName: 'Bakso Boedjangan',
      restaurantAddress: 'Jl. Telekomunikasi No. 50',
      location: const LatLng(-6.9720, 107.6355),
      startTime: DateTime.now().subtract(const Duration(hours: 3)),
      maxParticipants: 4,
      participantIds: ['user_2', 'user_1', 'user_5', 'user_4'],
      status: SessionStatus.completed,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'Bakso',
    ),
    SessionModel(
      id: 'session_5',
      creatorId: 'user_4',
      creatorName: 'Muhammad Ihsan',
      title: 'Mie Gacoan Yuk! 🌶️',
      description: 'Makan Mie Gacoan level angel bareng-bareng',
      restaurantName: 'Mie Gacoan',
      restaurantAddress: 'Jl. Bojongsoang No. 88',
      location: const LatLng(-6.9768, 107.6340),
      startTime: DateTime.now().add(const Duration(hours: 3)),
      maxParticipants: 6,
      participantIds: ['user_4', 'user_3'],
      status: SessionStatus.open,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      category: 'Mie Pedas',
    ),
  ];

  // ============ CHAT MESSAGES ============
  // Catatan: mock data sementara. Nanti diganti Firestore subcollection.
  // Field names sudah sesuai SPEC Section 5.5.
  static final List<ChatMessageModel> chatMessages = [
    // Session 1 chats
    ChatMessageModel(
      messageId: 'msg_1',
      senderId: 'user_1',
      senderName: 'Made Naradeon',
      text: 'Halo! Siapa yang mau ikut makan siang?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
    ChatMessageModel(
      messageId: 'msg_2',
      senderId: 'user_2',
      senderName: 'Revandi Akbar',
      text: 'Gue mau! Jam berapa ketemuan?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ChatMessageModel(
      messageId: 'msg_3',
      senderId: 'user_1',
      senderName: 'Made Naradeon',
      text: 'Jam 12 ya, di depan gerbang utama aja ketemunya',
      sentAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    ChatMessageModel(
      messageId: 'msg_4',
      senderId: 'user_2',
      senderName: 'Revandi Akbar',
      text: 'Oke siap! 👍',
      sentAt: DateTime.now().subtract(const Duration(minutes: 38)),
    ),

    // Session 3 chats
    ChatMessageModel(
      messageId: 'msg_5',
      senderId: 'user_3',
      senderName: 'Naemu Enggar',
      text: 'Geprek level berapa nih?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 100)),
    ),
    ChatMessageModel(
      messageId: 'msg_6',
      senderId: 'user_4',
      senderName: 'Muhammad Ihsan',
      text: 'Level 3 aja deh, takut sakit perut 😂',
      sentAt: DateTime.now().subtract(const Duration(minutes: 95)),
    ),
    ChatMessageModel(
      messageId: 'msg_7',
      senderId: 'user_2',
      senderName: 'Revandi Akbar',
      text: 'Gue level 5 sih, challenge!',
      sentAt: DateTime.now().subtract(const Duration(minutes: 90)),
    ),
    ChatMessageModel(
      messageId: 'msg_8',
      senderId: 'user_3',
      senderName: 'Naemu Enggar',
      text: 'Wkwk santai aja, masing-masing pilih level sendiri',
      sentAt: DateTime.now().subtract(const Duration(minutes: 85)),
    ),

    // Session 5 chats
    ChatMessageModel(
      messageId: 'msg_9',
      senderId: 'user_4',
      senderName: 'Muhammad Ihsan',
      text: 'Di Mie Gacoan yang di Bojongsoang ya',
      sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatMessageModel(
      messageId: 'msg_10',
      senderId: 'user_3',
      senderName: 'Naemu Enggar',
      text: 'Oke, gue otw jam 5 sore nanti',
      sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  // ============ REVIEWS ============
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'review_1',
      fromUserId: 'user_2',
      fromUserName: 'Revandi Akbar',
      toUserId: 'user_1',
      sessionId: 'session_4',
      rating: 5.0,
      comment: 'Orangnya asik, seru makan bareng!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewModel(
      id: 'review_2',
      fromUserId: 'user_1',
      fromUserName: 'Made Naradeon',
      toUserId: 'user_2',
      sessionId: 'session_4',
      rating: 4.5,
      comment: 'Fun banget, next time makan bareng lagi ya!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewModel(
      id: 'review_3',
      fromUserId: 'user_5',
      fromUserName: 'Saladin Setyo',
      toUserId: 'user_1',
      sessionId: 'session_4',
      rating: 4.0,
      comment: 'Good company, recommended!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // Food preference options
  static const List<String> foodPreferenceOptions = [
    'Sunda',
    'Padang',
    'Jepang',
    'Korea',
    'Western',
    'Pedas',
    'Seafood',
    'Vegetarian',
    'Bakso',
    'Mie',
    'Ayam Geprek',
    'Nasi Goreng',
    'Coffee',
    'Dessert',
    'Warteg',
  ];
}
