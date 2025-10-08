type TickListener = (now: number) => void;

// Explicit listener entry type to satisfy ArkTS rules against inline object types
interface ListenerEntry {
  id: number;
  fn: TickListener;
}

// Simple shared clock to emit once-per-second ticks to subscribers.
// Starts a single interval when the first subscriber registers and
// stops when the last unsubscribes.
let listeners: Array<ListenerEntry> = [];
let nextId = 1;
let intervalId: number | undefined = undefined;

function startInterval() {
  if (intervalId !== undefined) return;
  // align to next second for smoother display
  const align = 1000 - (Date.now() % 1000);
  setTimeout(() => {
    intervalId = setInterval(() => {
      const now = Date.now();
      for (let i = 0; i < listeners.length; i++) {
        try { listeners[i].fn(now); } catch (_) { }
      }
    }, 1000);
    // fire one immediately after alignment
    const now = Date.now();
    for (let i = 0; i < listeners.length; i++) {
      try { listeners[i].fn(now); } catch (_) { }
    }
  }, align);
}

function stopInterval() {
  if (intervalId !== undefined) {
    clearInterval(intervalId);
    intervalId = undefined;
  }
}

export function subscribeTick(listener: TickListener): number {
  const id = nextId++;
  listeners.push({ id, fn: listener });
  startInterval();
  return id;
}

export function unsubscribeTick(id: number): void {
  let idx = -1;
  for (let i = 0; i < listeners.length; i++) {
    if (listeners[i].id === id) { idx = i; break; }
  }
  if (idx !== -1) {
    listeners.splice(idx, 1);
  }
  if (listeners.length === 0) {
    stopInterval();
  }
}
