import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _date(dynamic value) =>
    value is Timestamp ? value.toDate() : DateTime.now();

class MindFlowUser {
  const MindFlowUser(
      {required this.uid,
      required this.username,
      required this.email,
      this.avatar = '',
      required this.createdAt});
  final String uid;
  final String username;
  final String email;
  final String avatar;
  final DateTime createdAt;

  factory MindFlowUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MindFlowUser(
      uid: doc.id,
      username: data['username'] ?? 'MindFlow student',
      email: data['email'] ?? '',
      avatar: data['avatar'] ?? '',
      createdAt: _date(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'username': username,
        'email': email,
        'avatar': avatar,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class MoodLog {
  const MoodLog(
      {required this.id,
      required this.uid,
      required this.mood,
      required this.note,
      required this.intensity,
      required this.createdAt});
  final String id;
  final String uid;
  final String mood;
  final String note;
  final int intensity;
  final DateTime createdAt;

  factory MoodLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MoodLog(
      id: doc.id,
      uid: data['uid'] ?? '',
      mood: data['mood'] ?? 'calm',
      note: data['note'] ?? '',
      intensity: data['intensity'] ?? 3,
      createdAt: _date(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'mood': mood,
        'note': note,
        'intensity': intensity,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp()
      };
}

class JournalEntry {
  const JournalEntry(
      {required this.id,
      required this.uid,
      required this.title,
      required this.body,
      required this.mood,
      this.photoUrl = '',
      required this.createdAt,
      required this.updatedAt});
  final String id;
  final String uid;
  final String title;
  final String body;
  final String mood;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JournalEntry(
      id: doc.id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      mood: data['mood'] ?? 'calm',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'body': body,
        'mood': mood,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt)
      };
}

class ChatMessage {
  const ChatMessage(
      {required this.id,
      required this.uid,
      required this.text,
      required this.isUser,
      required this.createdAt});
  final String id;
  final String uid;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessage(
        id: doc.id,
        uid: data['uid'] ?? '',
        text: data['text'] ?? '',
        isUser: data['isUser'] ?? false,
        createdAt: _date(data['createdAt']));
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'text': text,
        'isUser': isUser,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp()
      };
}

class CommunityPost {
  const CommunityPost(
      {required this.id,
      required this.uid,
      required this.text,
      required this.supportCount,
      required this.createdAt});
  final String id;
  final String uid;
  final String text;
  final int supportCount;
  final DateTime createdAt;

  factory CommunityPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CommunityPost(
        id: doc.id,
        uid: data['uid'] ?? '',
        text: data['text'] ?? '',
        supportCount: data['supportCount'] ?? 0,
        createdAt: _date(data['createdAt']));
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'text': text,
        'supportCount': supportCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp()
      };
}

class VoiceJournal {
  const VoiceJournal(
      {required this.id,
      required this.uid,
      required this.title,
      required this.audioUrl,
      required this.durationSeconds,
      required this.createdAt});
  final String id;
  final String uid;
  final String title;
  final String audioUrl;
  final int durationSeconds;
  final DateTime createdAt;

  factory VoiceJournal.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return VoiceJournal(
        id: doc.id,
        uid: data['uid'] ?? '',
        title: data['title'] ?? 'Voice reflection',
        audioUrl: data['audioUrl'] ?? '',
        durationSeconds: data['durationSeconds'] ?? 0,
        createdAt: _date(data['createdAt']));
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'audioUrl': audioUrl,
        'durationSeconds': durationSeconds,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp()
      };
}

class PhotoMemory {
  const PhotoMemory(
      {required this.id,
      required this.uid,
      required this.url,
      required this.caption,
      required this.createdAt});
  final String id;
  final String uid;
  final String url;
  final String caption;
  final DateTime createdAt;

  factory PhotoMemory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PhotoMemory(
        id: doc.id,
        uid: data['uid'] ?? '',
        url: data['url'] ?? '',
        caption: data['caption'] ?? '',
        createdAt: _date(data['createdAt']));
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'url': url,
        'caption': caption,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp()
      };
}
