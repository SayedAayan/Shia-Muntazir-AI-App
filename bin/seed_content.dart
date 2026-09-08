import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:muntazir/firebase_options.dart';
import 'package:muntazir/services/content_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  stdout.writeln('Connecting to Firebase project: ${DefaultFirebaseOptions.currentPlatform.projectId}...');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  stdout.writeln('Seeding real Quran Surahs, Duas, and Ziyarat texts to Firestore...');
  final seededCount = await ContentSeeder.seedContentToFirestore();
  stdout.writeln('SUCCESS: $seededCount content items successfully seeded to Firestore collection "content"!');
  exit(0);
}
