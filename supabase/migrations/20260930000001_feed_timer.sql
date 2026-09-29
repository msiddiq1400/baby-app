-- Breastfeeding timer: time per side, and a timer that keeps running while
-- the app is closed (its state lives in the feed row, so it survives a
-- restart and other caregivers see "feeding now" too).
--
--   left_seconds / right_seconds  time on each side, banked when switching
--                                 sides, pausing or finishing
--   timer_side                    set while the timer is going (running or
--                                 paused): the side it's on
--   timer_started_at              when the current side started running;
--                                 null while paused
--
-- A finished feed has timer_side and timer_started_at null and ended_at set.

alter table public.feeds
  add column left_seconds integer check (left_seconds >= 0),
  add column right_seconds integer check (right_seconds >= 0),
  add column timer_side text check (timer_side in ('left', 'right')),
  add column timer_started_at timestamptz,
  add constraint feeds_timer_needs_side check (timer_started_at is null or timer_side is not null);
