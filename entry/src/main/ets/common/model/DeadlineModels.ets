export interface TimelineEvent {
  deadline: string;
  comment: string;
}

export interface EventData {
  year: number;
  id: string;
  link: string;
  timeline: Array<TimelineEvent>;
  timezone: string;
  date: string;
  place: string;
}

export type CategoryType = 'conference' | 'competition' | 'activity';

export interface DeadlineItem {
  title: string;
  description: string;
  category: CategoryType;
  tags: Array<string>;
  events: Array<EventData>;
}

export interface FlatEvent {
  item: DeadlineItem;
  event: EventData;
  timeRemaining: number;
}

export function isEventEnded(event: EventData): boolean {
  if (!event.timeline || event.timeline.length === 0) {
    return false;
  }
  const lastDeadline = new Date(event.timeline[event.timeline.length - 1].deadline).getTime();
  return lastDeadline < Date.now();
}

export function nextUpcomingDeadline(event: EventData): TimelineEvent | undefined {
  const now = Date.now();
  let closest: TimelineEvent | undefined = undefined;
  event.timeline.forEach((timelineEvent) => {
    const timestamp = new Date(timelineEvent.deadline).getTime();
    if (timestamp >= now) {
      if (!closest || timestamp < new Date(closest.deadline).getTime()) {
        closest = timelineEvent;
      }
    }
  });
  return closest;
}
