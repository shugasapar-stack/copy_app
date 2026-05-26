import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../models/mindflow_models.dart';
import '../services/mindflow_repository.dart';

const moods = [
  'happy',
  'anxious',
  'lonely',
  'calm',
  'overwhelmed',
  'sad',
  'motivated',
  'tired'
];
const moodIcons = {
  'happy': ':-)',
  'anxious': ':|',
  'lonely': '..',
  'calm': '~',
  'overwhelmed': '!!',
  'sad': ':(',
  'motivated': '^',
  'tired': 'zz'
};

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(1100.ms, () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) => GradientScaffold(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const MindFlowMark(size: 104),
            const SizedBox(height: 22),
            Text('MindFlow',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Breathe. Reflect. Feel less alone.',
                style: TextStyle(color: Colors.white70)),
          ])
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(.94, .94)),
        ),
      );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => GradientScaffold(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 16),
          const MindFlowMark(size: 74),
          const SizedBox(height: 28),
          Text('Your private emotional reset space.',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w900, height: 1.05)),
          const SizedBox(height: 14),
          const Text(
              'Journal your day, track moods, talk through heavy moments, and find calm when everything feels loud.',
              style:
                  TextStyle(color: Colors.white70, height: 1.45, fontSize: 16)),
          const SizedBox(height: 24),
          const OnboardTile(
              icon: Icons.psychology_alt_outlined,
              title: 'AI emotional companion',
              text:
                  'Empathetic support that helps you reflect without pretending to replace therapy.'),
          const OnboardTile(
              icon: Icons.insights,
              title: 'Mood analytics',
              text:
                  'See patterns across your week and understand what your nervous system is saying.'),
          const OnboardTile(
              icon: Icons.diversity_1_outlined,
              title: 'Anonymous support',
              text:
                  'Share honestly and send support without profile pressure.'),
          const SizedBox(height: 20),
          FilledButton(
              onPressed: () => context.go('/register'),
              child: const Text('Create account')),
          TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('I already have an account')),
        ]),
      );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'Welcome back',
        subtitle: 'Let us pick up gently where you left off.',
        children: [
          TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 18),
          FilledButton(
              onPressed: loading ? null : _login,
              child: loading ? const ButtonLoader() : const Text('Sign in')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
              onPressed: loading ? null : _google,
              icon: const Icon(Icons.g_mobiledata, size: 30),
              label: const Text('Continue with Google')),
          TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Create new account')),
        ],
      );

  Future<void> _login() async => _run(
      () => ref.read(repositoryProvider).signIn(email.text, password.text));
  Future<void> _google() async =>
      _run(ref.read(repositoryProvider).signInWithGoogle);
  Future<void> _run(Future<void> Function() action) async {
    setState(() => loading = true);
    try {
      await action();
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) toast(context, friendlyError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'Start MindFlow',
        subtitle: 'A calm place for stressful weeks and honest thoughts.',
        children: [
          TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 18),
          FilledButton(
              onPressed: loading ? null : _register,
              child: loading
                  ? const ButtonLoader()
                  : const Text('Create account')),
          TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign in instead')),
        ],
      );

  Future<void> _register() async {
    if (name.text.trim().length < 2) {
      return toast(context, 'Add a username first.');
    }
    setState(() => loading = true);
    try {
      await ref.read(repositoryProvider).register(
          username: name.text, email: email.text, password: password.text);
      if (mounted) context.go('/verify');
    } catch (error) {
      if (mounted) toast(context, friendlyError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => GradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.mark_email_read_outlined,
                size: 74, color: MindFlowColors.pink),
            const SizedBox(height: 18),
            Text('Verify your email',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text(
                'We sent a verification link. After opening it, refresh your session to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 22),
            FilledButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser?.reload();
                  if (context.mounted &&
                      FirebaseAuth.instance.currentUser?.emailVerified ==
                          true) {
                    context.go('/home');
                  }
                },
                child: const Text('I verified')),
            TextButton(
                onPressed: ref.read(repositoryProvider).resendVerification,
                child: const Text('Resend email')),
            TextButton(
                onPressed: ref.read(repositoryProvider).signOut,
                child: const Text('Logout')),
          ]),
        ),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final screens = const [
    DashboardScreen(),
    AiChatScreen(),
    JournalScreen(),
    CommunityScreen(),
    ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) => GradientScaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'AI'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Journal'),
            NavigationDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum),
                label: 'Feed'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Me'),
          ],
        ),
        child: screens[index],
      );
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider).valueOrNull;
    final moodList = ref.watch(moodsProvider).valueOrNull ?? [];
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          Row(children: [
            const MindFlowMark(size: 42),
            const SizedBox(width: 12),
            Expanded(
                child: Text('Hi, ${user?.username.split(' ').first ?? 'there'}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900))),
            IconButton(
                onPressed: () => context.push('/comfort'),
                icon: const Icon(Icons.spa_outlined),
                tooltip: 'Comfort mode'),
          ]),
          const SizedBox(height: 18),
          Glass(
            padding: const EdgeInsets.all(22),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Right now check-in',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                  moodList.isEmpty
                      ? 'How is your mind flowing today?'
                      : 'Latest mood: ${moodList.first.mood}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: () => context.push('/moods'),
                  icon: const Icon(Icons.mood),
                  label: const Text('Log mood')),
            ]),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 3 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: const [
              FeatureTile(
                  route: '/chat',
                  icon: Icons.auto_awesome,
                  title: 'AI chat',
                  subtitle: 'Talk through it'),
              FeatureTile(
                  route: '/journal',
                  icon: Icons.edit_note,
                  title: 'Journal',
                  subtitle: 'Write privately'),
              FeatureTile(
                  route: '/voice',
                  icon: Icons.mic_none,
                  title: 'Voice',
                  subtitle: 'Record feelings'),
              FeatureTile(
                  route: '/analytics',
                  icon: Icons.insights,
                  title: 'Analytics',
                  subtitle: 'Mood patterns'),
              FeatureTile(
                  route: '/videos',
                  icon: Icons.play_circle_outline,
                  title: 'Videos',
                  subtitle: 'Motivation feed'),
              FeatureTile(
                  route: '/comfort',
                  icon: Icons.self_improvement,
                  title: 'Comfort',
                  subtitle: 'Calm down now'),
            ],
          ),
        ]);
  }
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final controller = TextEditingController();
  bool typing = false;

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    return Column(children: [
      const ScreenHeader(
          title: 'AI Emotional Chat',
          subtitle: 'Supportive reflection, not therapy.'),
      Expanded(
        child: messages.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            itemCount: items.length + (typing ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == items.length) return const TypingBubble();
              return ChatBubble(message: items[i]);
            },
          ),
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        hintText: 'Tell MindFlow what feels heavy...'))),
            const SizedBox(width: 10),
            IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
                tooltip: 'Send'),
          ]),
        ),
      ),
    ]);
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    final uid = ref.read(authProvider).currentUser?.uid;
    if (uid == null || text.isEmpty) return;
    controller.clear();
    final repo = ref.read(repositoryProvider);
    await repo.addChat(ChatMessage(
        id: '', uid: uid, text: text, isUser: true, createdAt: DateTime.now()));
    setState(() => typing = true);
    await Future.delayed(900.ms);
    await repo.addChat(ChatMessage(
        id: '',
        uid: uid,
        text: aiReplyFor(text),
        isUser: false,
        createdAt: DateTime.now()));
    if (mounted) setState(() => typing = false);
  }
}

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});
  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
  String selected = 'calm';
  double intensity = 3;
  final note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(moodsProvider);
    return GradientScaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final mood in moods)
                ChoiceChip(
                  selected: selected == mood,
                  label: Text('${moodIcons[mood]} $mood'),
                  onSelected: (_) => setState(() => selected = mood),
                ),
            ]),
            const SizedBox(height: 16),
            Glass(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Intensity ${intensity.round()}/5',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Slider(
                      value: intensity,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (v) => setState(() => intensity = v)),
                  TextField(
                      controller: note,
                      decoration:
                          const InputDecoration(labelText: 'Optional note')),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: _save, child: const Text('Save mood')),
                ])),
            const SectionTitle('Mood history'),
            history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (items) => Column(children: [
                EmotionalCalendar(moods: items),
                const SizedBox(height: 12),
                for (final mood in items)
                  Dismissible(
                    key: ValueKey(mood.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) =>
                        ref.read(repositoryProvider).deleteMood(mood.id),
                    background: const DeleteBg(),
                    child: ListTile(
                        title: Text('${moodIcons[mood.mood]} ${mood.mood}'),
                        subtitle: Text(
                            '${DateFormat.yMMMd().add_jm().format(mood.createdAt)}  ${mood.note}'),
                        trailing: Text('${mood.intensity}/5')),
                  ),
              ]),
            ),
          ]),
    );
  }

  Future<void> _save() async {
    final uid = ref.read(authProvider).currentUser?.uid;
    if (uid == null) return;
    await ref.read(repositoryProvider).saveMood(MoodLog(
        id: '',
        uid: uid,
        mood: selected,
        note: note.text.trim(),
        intensity: intensity.round(),
        createdAt: DateTime.now()));
    note.clear();
    if (mounted) toast(context, 'Mood saved.');
  }
}

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journals = ref.watch(journalsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Journal'), actions: [
        IconButton(
            onPressed: () => context.push('/voice'),
            icon: const Icon(Icons.mic_none))
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/journal/edit'),
          icon: const Icon(Icons.add),
          label: const Text('Entry')),
      body: journals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No entries yet',
                text: 'Write the first honest paragraph.')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => JournalCard(entry: items[i]),
              ),
      ),
    );
  }
}

class AddEditJournalScreen extends ConsumerStatefulWidget {
  const AddEditJournalScreen({super.key, this.entry});
  final Object? entry;
  @override
  ConsumerState<AddEditJournalScreen> createState() =>
      _AddEditJournalScreenState();
}

class _AddEditJournalScreenState extends ConsumerState<AddEditJournalScreen> {
  late final JournalEntry? entry =
      widget.entry is JournalEntry ? widget.entry as JournalEntry : null;
  late final title = TextEditingController(text: entry?.title ?? '');
  late final body = TextEditingController(text: entry?.body ?? '');
  String mood = 'calm';
  XFile? photo;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    mood = entry?.mood ?? 'calm';
  }

  @override
  Widget build(BuildContext context) => GradientScaffold(
        appBar:
            AppBar(title: Text(entry == null ? 'New Journal' : 'Edit Journal')),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          DropdownButtonFormField(
              initialValue: mood,
              items: moods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => mood = v ?? mood),
              decoration: const InputDecoration(labelText: 'Mood')),
          const SizedBox(height: 12),
          TextField(
              controller: body,
              minLines: 9,
              maxLines: 14,
              decoration: const InputDecoration(
                  labelText: 'What happened inside today?')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                  photo == null ? 'Attach emotional photo' : 'Photo selected')),
          const SizedBox(height: 18),
          FilledButton(
              onPressed: saving ? null : _save,
              child: saving ? const ButtonLoader() : const Text('Save entry')),
        ]),
      );

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked != null) {
      setState(() => photo = picked);
    }
  }

  Future<void> _save() async {
    final uid = ref.read(authProvider).currentUser?.uid;
    if (uid == null || title.text.trim().isEmpty || body.text.trim().isEmpty) {
      return toast(context, 'Title and body are required.');
    }
    setState(() => saving = true);
    var photoUrl = entry?.photoUrl ?? '';
    if (photo != null) {
      photoUrl = await ref.read(repositoryProvider).uploadPhotoMemory(
          uid: uid, photo: photo!, caption: title.text.trim());
    }
    await ref.read(repositoryProvider).saveJournal(JournalEntry(
        id: entry?.id ?? '',
        uid: uid,
        title: title.text.trim(),
        body: body.text.trim(),
        mood: mood,
        photoUrl: photoUrl,
        createdAt: entry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now()));
    if (mounted) context.pop();
  }
}

class VoiceJournalScreen extends ConsumerStatefulWidget {
  const VoiceJournalScreen({super.key});
  @override
  ConsumerState<VoiceJournalScreen> createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends ConsumerState<VoiceJournalScreen> {
  static const recorder = MethodChannel('mindflow/audio_recorder');
  bool recording = false;
  DateTime? started;

  @override
  Widget build(BuildContext context) {
    final voices = ref.watch(voiceProvider);
    return GradientScaffold(
      appBar: AppBar(title: const Text('Voice Journal')),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Glass(
            child: Column(children: [
          Icon(recording ? Icons.stop_circle_outlined : Icons.mic_none,
              size: 78,
              color: recording ? MindFlowColors.pink : MindFlowColors.blue),
          const SizedBox(height: 14),
          Text(
              recording
                  ? 'Recording your check-in...'
                  : 'Record a private emotional note',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: recording ? _stop : _start,
              child: Text(recording ? 'Stop and upload' : 'Start recording')),
        ])),
        const SectionTitle('Saved recordings'),
        voices.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (items) => Column(children: [
                  for (final item in items)
                    ListTile(
                        leading: const Icon(Icons.graphic_eq),
                        title: Text('${item.durationSeconds}s reflection'),
                        subtitle: Text(
                            DateFormat.yMMMd().add_jm().format(item.createdAt)),
                        trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () =>
                                launchUrl(Uri.parse(item.audioUrl)))),
                ])),
      ]),
    );
  }

  Future<void> _start() async {
    final path = await recorder.invokeMethod<String>('startRecording');
    if (!mounted) return;
    if (path == null) {
      return toast(context, 'Microphone permission is required.');
    }
    setState(() {
      recording = true;
      started = DateTime.now();
    });
  }

  Future<void> _stop() async {
    final path = await recorder.invokeMethod<String>('stopRecording');
    setState(() => recording = false);
    final uid = ref.read(authProvider).currentUser?.uid;
    if (uid != null && path != null) {
      final seconds = DateTime.now()
          .difference(started ?? DateTime.now())
          .inSeconds
          .clamp(1, 9999);
      await ref
          .read(repositoryProvider)
          .saveVoiceJournal(uid: uid, filePath: path, durationSeconds: seconds);
      if (mounted) toast(context, 'Voice journal uploaded.');
    }
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodsProvider);
    return GradientScaffold(
      appBar: AppBar(title: const Text('Emotional Analytics')),
      child: moodState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          final week = items
              .where((m) => m.createdAt
                  .isAfter(DateTime.now().subtract(const Duration(days: 7))))
              .toList();
          return ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              Expanded(child: Stat(label: 'Logs', value: '${items.length}')),
              const SizedBox(width: 12),
              Expanded(
                  child: Stat(label: 'This week', value: '${week.length}')),
            ]),
            const SizedBox(height: 16),
            Glass(
                child: SizedBox(
                    height: 230,
                    child: BarChart(BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        barGroups: _bars(week))))),
            const SectionTitle('Weekly insight'),
            Text(_insight(week),
                style: const TextStyle(color: Colors.white70, height: 1.45)),
          ]);
        },
      ),
    );
  }

  List<BarChartGroupData> _bars(List<MoodLog> logs) {
    final byDay = List.generate(
        7,
        (i) => logs
            .where((m) =>
                DateTime.now().subtract(Duration(days: 6 - i)).day ==
                m.createdAt.day)
            .fold<int>(0, (a, b) => a + b.intensity));
    return [
      for (var i = 0; i < byDay.length; i++)
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
              toY: byDay[i].toDouble(),
              color: i.isEven ? MindFlowColors.pink : MindFlowColors.blue,
              width: 18,
              borderRadius: BorderRadius.circular(8))
        ])
    ];
  }

  String _insight(List<MoodLog> week) => week.isEmpty
      ? 'Start logging moods to reveal your emotional rhythm.'
      : 'You checked in ${week.length} times this week. Notice what helped on calmer days and protect more of that.';
}

class MotivationVideosScreen extends StatelessWidget {
  const MotivationVideosScreen({super.key});
  @override
  Widget build(BuildContext context) => GradientScaffold(
        appBar: AppBar(title: const Text('Motivation Videos')),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          for (final video in motivationVideos) VideoCard(video: video),
        ]),
      );
}

class ComfortModeScreen extends StatefulWidget {
  const ComfortModeScreen({super.key});
  @override
  State<ComfortModeScreen> createState() => _ComfortModeScreenState();
}

class _ComfortModeScreenState extends State<ComfortModeScreen>
    with SingleTickerProviderStateMixin {
  late final controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat(reverse: true);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GradientScaffold(
        appBar: AppBar(title: const Text('Comfort Mode')),
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 22),
          Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final size = 170 + controller.value * 70;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        MindFlowColors.pink.withValues(alpha: .62),
                        MindFlowColors.blue.withValues(alpha: .14),
                      ],
                    ),
                  ),
                  child: const Center(
                      child: Text('Breathe',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 22))),
                );
              },
            ),
          ),
          const SizedBox(height: 38),
          const Glass(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Grounding now',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                SizedBox(height: 12),
                Text(
                    'Name 5 things you see.\nName 4 things you feel.\nName 3 sounds around you.\nUnclench your jaw.\nLower your shoulders.',
                    style: TextStyle(height: 1.55, color: Colors.white70)),
              ])),
        ]),
      );
}

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final text = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityProvider);
    return Column(children: [
      const ScreenHeader(
          title: 'Anonymous Feed',
          subtitle: 'Post thoughts. Send support. Stay kind.'),
      Padding(
          padding: const EdgeInsets.all(16),
          child: Glass(
              child: Column(children: [
            TextField(
                controller: text,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'What do you need to say anonymously?')),
            const SizedBox(height: 10),
            FilledButton(
                onPressed: _post, child: const Text('Post anonymously')),
          ]))),
      Expanded(
          child: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
            itemCount: items.length,
            itemBuilder: (context, i) => CommunityCard(post: items[i])),
      )),
    ]);
  }

  Future<void> _post() async {
    final uid = ref.read(authProvider).currentUser?.uid;
    if (uid == null || text.text.trim().isEmpty) return;
    await ref.read(repositoryProvider).savePost(CommunityPost(
        id: '',
        uid: uid,
        text: text.text.trim(),
        supportCount: 0,
        createdAt: DateTime.now()));
    text.clear();
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final photos = ref.watch(photosProvider).valueOrNull ?? [];
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          Center(
              child: CircleAvatar(
                  radius: 42,
                  backgroundImage: profile?.avatar.isNotEmpty == true
                      ? NetworkImage(profile!.avatar)
                      : null,
                  child: profile?.avatar.isNotEmpty == true
                      ? null
                      : const Icon(Icons.person, size: 42))),
          const SizedBox(height: 12),
          Text(profile?.username ?? 'MindFlow student',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          Text(profile?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 18),
          FilledButton.icon(
              onPressed: () => _uploadMemory(context, ref),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Upload photo memory')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: () => ref.read(repositoryProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout')),
          const SectionTitle('Photo memories'),
          GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final photo in photos)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                          imageUrl: photo.url, fit: BoxFit.cover)),
              ]),
        ]);
  }

  Future<void> _uploadMemory(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(authProvider).currentUser?.uid;
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (uid != null && image != null) {
      await ref
          .read(repositoryProvider)
          .uploadPhotoMemory(uid: uid, photo: image, caption: 'Daily memory');
      if (!context.mounted) return;
      toast(context, 'Photo memory uploaded.');
    }
  }
}

class MindFlowMark extends StatelessWidget {
  const MindFlowMark({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * .28),
            gradient: const LinearGradient(colors: [
              MindFlowColors.purple,
              MindFlowColors.pink,
              MindFlowColors.blue
            ])),
        child: Icon(Icons.water_drop_rounded,
            size: size * .55, color: Colors.white),
      );
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.children});
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => GradientScaffold(
          child: ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 38),
        const MindFlowMark(size: 64),
        const SizedBox(height: 28),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 24),
        ...children,
      ]));
}

class OnboardTile extends StatelessWidget {
  const OnboardTile(
      {super.key, required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Glass(
          child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: MindFlowColors.pink),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(text))));
}

class FeatureTile extends StatelessWidget {
  const FeatureTile(
      {super.key,
      required this.route,
      required this.icon,
      required this.title,
      required this.subtitle});
  final String route;
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Glass(
      onTap: () => context.push(route),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: MindFlowColors.pink),
        const Spacer(),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]));
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        Text(subtitle, style: const TextStyle(color: Colors.white60)),
      ]));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900)));
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;
  @override
  Widget build(BuildContext context) => Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: message.isUser
                ? MindFlowColors.purple
                : Colors.white.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: Radius.circular(message.isUser ? 4 : 20),
                bottomLeft: Radius.circular(message.isUser ? 20 : 4)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message.text, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 5),
            Text(DateFormat.Hm().format(message.createdAt),
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ),
      );
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(20)),
          child: const Text('MindFlow is typing...')));
}

class EmotionalCalendar extends StatelessWidget {
  const EmotionalCalendar({super.key, required this.moods});
  final List<MoodLog> moods;
  @override
  Widget build(BuildContext context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        children: [
          for (var i = 20; i >= 0; i--)
            CalendarDot(
                log: moods
                    .where((m) => DateUtils.isSameDay(m.createdAt,
                        DateTime.now().subtract(Duration(days: i))))
                    .firstOrNull)
        ],
      );
}

class CalendarDot extends StatelessWidget {
  const CalendarDot({super.key, this.log});
  final MoodLog? log;
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: log == null
              ? Colors.white10
              : MindFlowColors.pink
                  .withValues(alpha: .25 + min(log!.intensity, 5) * .12)),
      child:
          Center(child: Text(log == null ? '' : moodIcons[log!.mood] ?? '')));
}

class JournalCard extends ConsumerWidget {
  const JournalCard({super.key, required this.entry});
  final JournalEntry entry;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Glass(
      onTap: () => context.push('/journal/edit', extra: entry),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(entry.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 18))),
          IconButton(
              onPressed: () =>
                  ref.read(repositoryProvider).deleteJournal(entry.id),
              icon: const Icon(Icons.delete_outline))
        ]),
        Text('${entry.mood}  ${DateFormat.yMMMd().format(entry.updatedAt)}',
            style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 8),
        Text(entry.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, height: 1.4)),
      ]));
}

class CommunityCard extends ConsumerWidget {
  const CommunityCard({super.key, required this.post});
  final CommunityPost post;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Glass(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Anonymous student',
            style: TextStyle(
                color: MindFlowColors.blue, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(post.text, style: const TextStyle(height: 1.4)),
        const SizedBox(height: 10),
        Row(children: [
          Text(DateFormat.MMMd().add_jm().format(post.createdAt),
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const Spacer(),
          TextButton.icon(
              onPressed: () =>
                  ref.read(repositoryProvider).supportPost(post.id),
              icon: const Icon(Icons.favorite_border),
              label: Text('${post.supportCount}')),
          if (post.uid == ref.read(authProvider).currentUser?.uid)
            IconButton(
                onPressed: () =>
                    ref.read(repositoryProvider).deletePost(post.id),
                icon: const Icon(Icons.delete_outline)),
        ]),
      ])));
}

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video});
  final ({String title, String category, String id}) video;
  @override
  Widget build(BuildContext context) {
    final thumb = 'https://img.youtube.com/vi/${video.id}/hqdefault.jpg';
    return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Glass(
            onTap: () => launchUrl(
                Uri.parse('https://www.youtube.com/watch?v=${video.id}')),
            padding: EdgeInsets.zero,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                  child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                          imageUrl: thumb, fit: BoxFit.cover))),
              Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video.category,
                            style: const TextStyle(
                                color: MindFlowColors.pink,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(video.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                      ])),
            ])));
  }
}

class Stat extends StatelessWidget {
  const Stat({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Glass(
          child: Column(children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900, color: MindFlowColors.pink)),
        Text(label, style: const TextStyle(color: Colors.white60))
      ]));
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key, required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 64, color: MindFlowColors.pink),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60))
          ])));
}

class DeleteBg extends StatelessWidget {
  const DeleteBg({super.key});
  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 18),
      color: Colors.redAccent.withValues(alpha: .35),
      child: const Icon(Icons.delete_outline));
}

class ButtonLoader extends StatelessWidget {
  const ButtonLoader({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
}

void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));

const motivationVideos = [
  (
    title: 'Study motivation for deep focus',
    category: 'study motivation',
    id: 'mgmVOuLgFB0'
  ),
  (
    title: 'Calm anxiety with slow breathing',
    category: 'anxiety relief',
    id: 'inpok4MKVLM'
  ),
  (title: 'Build quiet confidence', category: 'confidence', id: 'wnHW6o8WMas'),
  (
    title: 'Recover from burnout gently',
    category: 'burnout recovery',
    id: 'jqONINYF17M'
  ),
  (title: 'Sleep reset for students', category: 'sleep', id: 'aEqlQvczMJQ'),
  (
    title: 'Small habits, better self',
    category: 'self-improvement',
    id: '75d_29QWELk'
  ),
];

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
