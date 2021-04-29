// Copyright (c) 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' show HttpOverrides;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hf_retry/hf_retry.dart';
import 'package:quiver/testing/async.dart';

String _imageUrl(
    {String fileName =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1200px-Image_created_with_a_mobile_phone.png'}) {
  return fileName;
}

void assertThatImageLoadingFails(
    NetworkImageWithRetry subject, List<FlutterErrorDetails> errorLog) {
  subject
      .load(subject, PaintingBinding.instance!.instantiateImageCodec)
      .addListener(ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {},
        onError: expectAsync2((Object error, StackTrace? _) {
          expect(errorLog.single.exception, isInstanceOf<FetchFailure>());
          expect(error, isInstanceOf<FetchFailure>());
          expect(error, equals(errorLog.single.exception));
        }),
      ));
}

void main() {
  AutomatedTestWidgetsFlutterBinding();
  HttpOverrides.global = null;

  group('NetworkImageWithRetry', () {
    setUp(() {
      FlutterError.onError = (FlutterErrorDetails error) {
        fail('$error');
      };
    });

    tearDown(() {
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });

    test('loads image from network', () async {
      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl(),
      );

      subject
          .load(subject, PaintingBinding.instance!.instantiateImageCodec)
          .addListener(
        ImageStreamListener(
            expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(image.image.height, 900);
          expect(image.image.width, 1200);
        })),
      );
    });

    test('gives up immediately on non-retriable errors (HTTP 404)', () async {
      final List<FlutterErrorDetails> errorLog = <FlutterErrorDetails>[];
      FlutterError.onError = errorLog.add;

      final FakeAsync fakeAsync = FakeAsync();

      int attemptCount = 0;
      Future<void> onAttempt() async {
        expect(attemptCount, lessThan(2));
        await Future<void>.delayed(Duration.zero);
        fakeAsync.elapse(const Duration(seconds: 60));
        attemptCount++;
      }

      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl(),
        fetchStrategy: (Uri uri, FetchFailure? failure) {
          Timer.run(onAttempt);
          return fakeAsync.run((FakeAsync fakeAsync) {
            return NetworkImageWithRetry.defaultFetchStrategy(uri, failure);
          });
        },
      );

      subject
          .load(subject, PaintingBinding.instance!.instantiateImageCodec)
          .addListener(
        ImageStreamListener(
            expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(errorLog.single.exception, isInstanceOf<FetchFailure>());
          expect(image, null);
        })),
      );
    });

    test('succeeds on successful retry', () async {
      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl(),
        fetchStrategy: (Uri uri, FetchFailure? failure) async {
          if (failure == null) {
            return FetchInstructions.attempt(
              uri: uri,
              timeout: const Duration(minutes: 1),
            );
          } else {
            expect(failure.attemptCount, lessThan(2));
            return FetchInstructions.attempt(
              uri: Uri.parse(_imageUrl()),
              timeout: const Duration(minutes: 1),
            );
          }
        },
      );

      subject
          .load(subject, PaintingBinding.instance!.instantiateImageCodec)
          .addListener(
        ImageStreamListener(
            expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(image.image.height, 900);
          expect(image.image.width, 1200);
        })),
      );
    });
  });
}
