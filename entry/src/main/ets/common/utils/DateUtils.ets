export function formatDeadline(dateString: string): string {
  const date = new Date(dateString);
  if (isNaN(date.getTime())) {
    return dateString;
  }

  const year = date.getFullYear();
  const month = padZero(date.getMonth() + 1);
  const day = padZero(date.getDate());
  const hours = padZero(date.getHours());
  const minutes = padZero(date.getMinutes());
  const seconds = padZero(date.getSeconds());

  const timezoneOffset = -date.getTimezoneOffset();
  const offsetHours = Math.floor(Math.abs(timezoneOffset) / 60);
  const offsetMinutes = Math.abs(timezoneOffset) % 60;
  const offsetSign = timezoneOffset >= 0 ? '+' : '-';
  const timezoneString = `UTC${offsetSign}${padZero(offsetHours)}:${padZero(offsetMinutes)}`;

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds} (${timezoneString})`;
}

export function formatTimelineDate(dateString: string): string {
  const date = new Date(dateString);
  if (isNaN(date.getTime())) {
    return dateString;
  }
  return `${padZero(date.getMonth() + 1)}-${padZero(date.getDate())}`;
}

export function describeTimeLeft(delta: number): string {
  if (delta <= 0) {
    return '已过期';
  }
  const seconds = Math.floor(delta / 1000);
  const days = Math.floor(seconds / (60 * 60 * 24));
  const hours = Math.floor((seconds % (60 * 60 * 24)) / (60 * 60));
  const minutes = Math.floor((seconds % (60 * 60)) / 60);
  return `${days}天 ${hours}小时 ${minutes}分钟`;
}

function padZero(value: number): string {
  return value.toString().padStart(2, '0');
}
