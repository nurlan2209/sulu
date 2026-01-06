import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/badges_api.dart';

final badgesControllerProvider = FutureProvider<List<String>>((ref) => ref.watch(badgesApiProvider).list());

