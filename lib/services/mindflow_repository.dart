import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../models/mindflow_models.dart';

class MindFlowRepository {
  MindFlowRepository(this.auth, this.db, this.storage);
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  final FirebaseStorage storage;

  User? get currentUser => auth.currentUser;
  Stream<User?> authChanges() => auth.authStateChanges();

  Future<void> register(
      {required String username,
      required String email,
      required String password}) async {
    final result = await auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim());
    await result.user?.updateDisplayName(username.trim());
    await result.user?.sendEmailVerification();
    await upsertUser(MindFlowUser(
        uid: result.user!.uid,
        username: username.trim(),
        email: email.trim(),
        avatar: '',
        createdAt: DateTime.now()));
  }

  Future<void> signIn(String email, String password) =>
      auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

  Future<void> signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) return;
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final result = await auth.signInWithCredential(credential);
    final user = result.user!;
    await upsertUser(MindFlowUser(
        uid: user.uid,
        username: user.displayName ?? 'MindFlow student',
        email: user.email ?? '',
        avatar: user.photoURL ?? '',
        createdAt: DateTime.now()));
  }

  Future<void> resendVerification() async =>
      auth.currentUser?.sendEmailVerification();

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await auth.signOut();
  }

  Future<void> upsertUser(MindFlowUser user) => db
      .collection('users')
      .doc(user.uid)
      .set(user.toMap(), SetOptions(merge: true));
  Stream<MindFlowUser?> profile(String uid) => db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? MindFlowUser.fromDoc(doc) : null);

  Stream<List<JournalEntry>> journals(String uid) => db
          .collection('journals')
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((s) {
        final items = s.docs.map(JournalEntry.fromDoc).toList();
        items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return items;
      });
  Future<void> saveJournal(JournalEntry entry) {
    final ref = entry.id.isEmpty
        ? db.collection('journals').doc()
        : db.collection('journals').doc(entry.id);
    return ref.set(entry.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteJournal(String id) =>
      db.collection('journals').doc(id).delete();

  Stream<List<MoodLog>> moods(String uid) =>
      db.collection('moods').where('uid', isEqualTo: uid).snapshots().map((s) {
        final items = s.docs.map(MoodLog.fromDoc).toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });
  Future<void> saveMood(MoodLog mood) {
    final ref = mood.id.isEmpty
        ? db.collection('moods').doc()
        : db.collection('moods').doc(mood.id);
    return ref.set(mood.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteMood(String id) => db.collection('moods').doc(id).delete();

  Stream<List<ChatMessage>> chat(String uid) => db
      .collection('ai_chats')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(ChatMessage.fromDoc).toList());
  Future<void> addChat(ChatMessage message) =>
      db.collection('ai_chats').add(message.toMap());

  Stream<List<CommunityPost>> community() => db
      .collection('community_posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(CommunityPost.fromDoc).toList());
  Future<void> savePost(CommunityPost post) {
    final ref = post.id.isEmpty
        ? db.collection('community_posts').doc()
        : db.collection('community_posts').doc(post.id);
    return ref.set(post.toMap(), SetOptions(merge: true));
  }

  Future<void> deletePost(String id) =>
      db.collection('community_posts').doc(id).delete();
  Future<void> supportPost(String id) =>
      db.collection('community_posts').doc(id).update({
        'supportCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp()
      });

  Stream<List<VoiceJournal>> voiceJournals(String uid) => db
          .collection('voice_journals')
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((s) {
        final items = s.docs.map(VoiceJournal.fromDoc).toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });
  Future<void> saveVoiceJournal(
      {required String uid,
      required String filePath,
      required int durationSeconds}) async {
    final file = File(filePath);
    final ref = storage.ref(
        'voice_journals/$uid/${DateTime.now().millisecondsSinceEpoch}.m4a');
    await ref.putFile(file, SettableMetadata(contentType: 'audio/mp4'));
    final url = await ref.getDownloadURL();
    await db.collection('voice_journals').add(VoiceJournal(
            id: '',
            uid: uid,
            audioUrl: url,
            durationSeconds: durationSeconds,
            createdAt: DateTime.now())
        .toMap());
  }

  Stream<List<PhotoMemory>> photoMemories(String uid) => db
          .collection('photo_memories')
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((s) {
        final items = s.docs.map(PhotoMemory.fromDoc).toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });
  Future<String> uploadPhotoMemory(
      {required String uid,
      required XFile photo,
      required String caption}) async {
    final bytes = await photo.readAsBytes();
    final ref = storage.ref(
        'photo_memories/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putData(
        bytes, SettableMetadata(contentType: photo.mimeType ?? 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await db.collection('photo_memories').add(PhotoMemory(
            id: '',
            uid: uid,
            url: url,
            caption: caption,
            createdAt: DateTime.now())
        .toMap());
    return url;
  }
}

String aiReplyFor(String input) {
  final text = input.toLowerCase();
  if (text.contains('exhaust') ||
      text.contains('tired') ||
      text.contains('burnout')) {
    return 'Sounds like today drained you emotionally. Want to talk about what made it feel so heavy? We can slow it down together.';
  }
  if (text.contains('anx') ||
      text.contains('panic') ||
      text.contains('overthink')) {
    return 'That anxious loop can feel loud. Try naming five things you can see, then tell me the thought that keeps repeating.';
  }
  if (text.contains('lonely') || text.contains('alone')) {
    return 'Feeling lonely does not mean you are hard to love. I am here with you. What moment today made the loneliness spike?';
  }
  if (text.contains('sad') || text.contains('cry')) {
    return 'I am sorry it hurts right now. You do not have to solve the whole feeling at once. What would feel 2 percent gentler in the next ten minutes?';
  }
  return 'I hear you. That feeling makes sense from where you are standing. Tell me a little more, and we will untangle the next small step.';
}

String friendlyError(Object error) {
  final text = error.toString();
  if (text.contains('invalid-credential') || text.contains('wrong-password')) {
    return 'Email or password is incorrect.';
  }
  if (text.contains('email-already-in-use')) {
    return 'That email already has a MindFlow account.';
  }
  if (text.contains('weak-password')) {
    return 'Use at least 6 characters for your password.';
  }
  if (text.contains('network')) {
    return 'Network connection failed. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
