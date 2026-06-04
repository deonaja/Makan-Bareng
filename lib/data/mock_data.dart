import 'package:latlong2/latlong.dart';
import '../models/user_model.dart';
import '../models/chat_message_model.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

class MockData {
  MockData._();

  // ============ USERS ============
  static final List<UserModel> users = [
    UserModel(
      uid: 'user_1',
      name: 'Made Naradeon',
      email: 'naradeon@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Suka makan pedas dan eksplor tempat makan baru 🌶️',
      foodPreferences: ['Pedas', 'Sunda', 'Seafood'],
      averageRating: 4.8,
      sessionsCreated: 8,
      sessionsJoined: 7,
      createdAt: DateTime(2025, 1, 15),
      updatedAt: DateTime(2025, 1, 15),
      lastLoginAt: DateTime(2025, 1, 15),
    ),
    UserModel(
      uid: 'user_2',
      name: 'Revandi Akbar',
      email: 'revandi@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Foodie sejati, makan adalah seni 🍜',
      foodPreferences: ['Jepang', 'Korea', 'Western'],
      averageRating: 4.5,
      sessionsCreated: 5,
      sessionsJoined: 7,
      createdAt: DateTime(2025, 2, 1),
      updatedAt: DateTime(2025, 2, 1),
      lastLoginAt: DateTime(2025, 2, 1),
    ),
    UserModel(
      uid: 'user_3',
      name: 'Naemu Enggar',
      email: 'naemu@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Vegetarian friendly, tapi suka coba semuanya ✌️',
      foodPreferences: ['Vegetarian', 'Salad', 'Jus'],
      averageRating: 4.7,
      sessionsCreated: 4,
      sessionsJoined: 6,
      createdAt: DateTime(2025, 2, 10),
      updatedAt: DateTime(2025, 2, 10),
      lastLoginAt: DateTime(2025, 2, 10),
    ),
    UserModel(
      uid: 'user_4',
      name: 'Muhammad Ihsan',
      email: 'ihsan@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Coffee addict ☕ & nasi goreng enthusiast',
      foodPreferences: ['Nasi Goreng', 'Coffee', 'Bakso'],
      averageRating: 4.3,
      sessionsCreated: 3,
      sessionsJoined: 5,
      createdAt: DateTime(2025, 3, 5),
      updatedAt: DateTime(2025, 3, 5),
      lastLoginAt: DateTime(2025, 3, 5),
    ),
    UserModel(
      uid: 'user_5',
      name: 'Saladin Setyo',
      email: 'saladin@student.telkomuniversity.ac.id',
      photoUrl: '',
      bio: 'Anak kos yang suka patungan makan 💰',
      foodPreferences: ['Warteg', 'Padang', 'Ayam Geprek'],
      averageRating: 4.6,
      sessionsCreated: 10,
      sessionsJoined: 10,
      createdAt: DateTime(2025, 1, 20),
      updatedAt: DateTime(2025, 1, 20),
      lastLoginAt: DateTime(2025, 1, 20),
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
      reviewId: 'review_1',
      reviewerId: 'user_2',
      reviewerName: 'Revandi Akbar',
      reviewerPhotoUrl: 'https://ui-avatars.com/api/?name=Revandi+Akbar&background=random',
      revieweeId: 'user_1',
      revieweeName: 'Made Naradeon',
      sessionId: 'session_4',
      sessionTitle: 'Makan Nasi Ampera',
      rating: 5.0,
      comment: 'Orangnya asik, seru makan bareng!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewModel(
      reviewId: 'review_2',
      reviewerId: 'user_1',
      reviewerName: 'Made Naradeon',
      reviewerPhotoUrl: 'https://ui-avatars.com/api/?name=Made+Naradeon&background=random',
      revieweeId: 'user_2',
      revieweeName: 'Revandi Akbar',
      sessionId: 'session_4',
      sessionTitle: 'Makan Nasi Ampera',
      rating: 4.5,
      comment: 'Fun banget, next time makan bareng lagi ya!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewModel(
      reviewId: 'review_3',
      reviewerId: 'user_5',
      reviewerName: 'Saladin Setyo',
      reviewerPhotoUrl: 'https://ui-avatars.com/api/?name=Saladin+Setyo&background=random',
      revieweeId: 'user_1',
      revieweeName: 'Made Naradeon',
      sessionId: 'session_4',
      sessionTitle: 'Makan Nasi Ampera',
      rating: 4.0,
      comment: 'Good company, recommended!',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
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
