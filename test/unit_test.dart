// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import '../lib/src/services/dbService.dart';
import '../lib/src/model/commentModel.dart';

void main() {
  test('Test getAllPost', () async {

    final databaseService = DatabaseService();

    final posts = await databaseService.getAllPost();

    expect(posts, isNotEmpty);

    for (final post in posts) {
      expect(post.id_user, isNotNull);
      expect(post.title, isNotNull);
      expect(post.text, isNotNull);
      expect(post.id_category, isNotNull);
    }
  });

  test('Test getCategory', () async {
    final databaseService = DatabaseService();

    final categoryId = 'Br9oHfeGNTyXMgT0dgGT';

    final category = await databaseService.getCategory(categoryId);

    expect(category, isNotNull);

  });

  test('Test getAllComment', () async {

    final databaseService = DatabaseService();
    String id = 'post_123';

    final comments = await databaseService.getAllComment(id);

    expect(comments, isNotEmpty);

  });

  test('Test getUserStatus', () async {
    final databaseService = DatabaseService();

    final userId = 'aMFrD6baIgOewuFALz4RFbjTZIS2';

    final status = await databaseService.getUserStatus(userId);

    expect(status, true);
  });
}
