import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mindflow_models.dart';
import '../services/mindflow_repository.dart';

final authProvider = Provider((_) => FirebaseAuth.instance);
final firestoreProvider = Provider((_) => FirebaseFirestore.instance);
final storageProvider = Provider((_) => FirebaseStorage.instance);

final repositoryProvider = Provider((ref) => MindFlowRepository(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
    ref.watch(storageProvider)));
final authStateProvider =
    StreamProvider((ref) => ref.watch(repositoryProvider).authChanges());

final profileProvider = StreamProvider<MindFlowUser?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user == null
      ? Stream.value(null)
      : ref.watch(repositoryProvider).profile(user.uid);
});

final journalsProvider = StreamProvider<List<JournalEntry>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user == null
      ? Stream.value(<JournalEntry>[])
      : ref.watch(repositoryProvider).journals(user.uid);
});

final moodsProvider = StreamProvider<List<MoodLog>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user == null
      ? Stream.value(<MoodLog>[])
      : ref.watch(repositoryProvider).moods(user.uid);
});

final chatProvider = StreamProvider<List<ChatMessage>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user == null
      ? Stream.value(<ChatMessage>[])
      : ref.watch(repositoryProvider).chat(user.uid);
});

final communityProvider = StreamProvider<List<CommunityPost>>(
    (ref) => ref.watch(repositoryProvider).community());

final voiceProvider = StreamProvider<List<VoiceJournal>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user == null
      ? Stream.value(<VoiceJournal>[])
      : ref.watch(repositoryProvider).voiceJournals(user.uid);
});

final photosProvider = StreamProvider<List<PhotoMemory>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user == null
      ? Stream.value(<PhotoMemory>[])
      : ref.watch(repositoryProvider).photoMemories(user.uid);
});
