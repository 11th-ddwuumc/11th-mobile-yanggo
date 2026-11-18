import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/main.dart';

void main() {
  testWidgets('시작 화면에 필요한 요소가 보이는지 확인', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });
}
