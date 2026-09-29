import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/home/live_timers.dart';
import 'package:baby_app/features/home/log_sheets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 9, 30, 10);
  DateTime at(int minutes, [int seconds = 0]) => t0.add(Duration(minutes: minutes, seconds: seconds));

  Feed timer({int left = 0, int right = 0, BreastSide side = BreastSide.left, DateTime? runningSince}) => Feed(
        id: 'f',
        type: FeedType.breast,
        startedAt: t0,
        leftSeconds: left,
        rightSeconds: right,
        timerSide: side,
        timerStartedAt: runningSince,
      );

  test('the running side counts up; the other side keeps its banked time', () {
    final feed = timer(left: 300, side: BreastSide.right, runningSince: at(5));
    expect(feed.secondsOn(BreastSide.left, at(12)), 300);
    expect(feed.secondsOn(BreastSide.right, at(12)), 7 * 60);
    expect(feed.duration(at(12)), const Duration(minutes: 12));
    expect(feed.timerActive, isTrue);
    expect(feed.timerPaused, isFalse);
  });

  test('a paused timer does not count up', () {
    final feed = timer(left: 300, right: 120, side: BreastSide.right);
    expect(feed.timerPaused, isTrue);
    expect(feed.duration(at(60)), const Duration(seconds: 420));
    expect(feed.bankedAt(at(60)), (300, 120));
  });

  test('banking adds the running segment to its side', () {
    final feed = timer(left: 60, side: BreastSide.left, runningSince: at(1));
    expect(feed.bankedAt(at(4, 30)), (60 + 210, 0));
  });

  test('a clock set backwards never gives negative time', () {
    final feed = timer(side: BreastSide.left, runningSince: at(10));
    expect(feed.secondsOn(BreastSide.left, at(5)), 0);
  });

  test('side from the time on each side', () {
    expect(sideFromSeconds(300, 0), BreastSide.left);
    expect(sideFromSeconds(0, 60), BreastSide.right);
    expect(sideFromSeconds(300, 60), BreastSide.both);
    expect(sideFromSeconds(0, 0), isNull);
  });

  test('older feeds without per-side times are split for editing', () {
    Feed old(BreastSide side, int minutes) =>
        Feed(id: 'o', type: FeedType.breast, startedAt: t0, endedAt: at(minutes), side: side);
    expect(secondsPerSide(old(BreastSide.left, 10)), (600, null));
    expect(secondsPerSide(old(BreastSide.right, 10)), (null, 600));
    expect(secondsPerSide(old(BreastSide.both, 15)), (450, 450));
    expect(secondsPerSide(Feed(id: 'n', type: FeedType.breast, startedAt: t0)), (null, null));
    expect(secondsPerSide(Feed(id: 'p', type: FeedType.breast, startedAt: t0, leftSeconds: 90)), (90, null));
  });

  test('finished feeds without a timer use start to end', () {
    final feed = Feed(id: 'b', type: FeedType.bottleFormula, startedAt: t0, endedAt: at(15), amountMl: 120);
    expect(feed.duration(at(99)), const Duration(minutes: 15));
    expect(feed.timerActive, isFalse);
  });

  test('clock text', () {
    expect(clockText(const Duration(seconds: 5)), '00:05');
    expect(clockText(const Duration(minutes: 12, seconds: 30)), '12:30');
    expect(clockText(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    expect(clockText(const Duration(seconds: -4)), '00:00');
  });
}
