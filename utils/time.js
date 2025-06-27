// File: utils/time.js

export function formatTimestamp(timestamp) {
  const date = new Date(timestamp * 1000); // Convert UNIX to milliseconds
  return date.toLocaleString(); // You can customize locale if needed
}

export function timeAgo(timestamp) {
  const now = Math.floor(Date.now() / 1000);
  const seconds = now - timestamp;

  const units = [
    { name: "day", secs: 86400 },
    { name: "hour", secs: 3600 },
    { name: "minute", secs: 60 },
    { name: "second", secs: 1 },
  ];

  for (const unit of units) {
    const count = Math.floor(seconds / unit.secs);
    if (count > 0) {
      return `${count} ${unit.name}${count > 1 ? "s" : ""} ago`;
    }
  }
  return "just now";
}

export function hoursLeft(from, to) {
  const seconds = to - from;
  return Math.max(Math.floor(seconds / 3600), 0);
}

export function toUnixSeconds(days = 0, hours = 0) {
  return days * 86400 + hours * 3600;
}

export function nowUnix() {
  return Math.floor(Date.now() / 1000);
}
