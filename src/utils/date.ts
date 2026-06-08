import {
  eachDayOfInterval,
  endOfWeek,
  format,
  formatDistanceToNowStrict,
  parseISO,
  startOfWeek,
} from 'date-fns';

export function getWeekRange(date = new Date()) {
  const start = startOfWeek(date, { weekStartsOn: 1 });
  const end = endOfWeek(date, { weekStartsOn: 1 });

  return {
    start,
    end,
    days: eachDayOfInterval({ start, end }),
    label: `${format(start, 'MMM d')} - ${format(end, 'MMM d')}`,
  };
}

export function toDateKey(date: Date) {
  return format(date, 'yyyy-MM-dd');
}

export function formatDateShort(value?: string) {
  if (!value) {
    return 'Never';
  }

  return format(parseISO(value), 'MMM d, yyyy');
}

export function formatRelativeDate(value?: string) {
  if (!value) {
    return 'Never';
  }

  return `${formatDistanceToNowStrict(parseISO(value), { addSuffix: true })}`;
}
