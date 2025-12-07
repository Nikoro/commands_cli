String link(String text, String url) {
  const esc = '\x1B';
  return '$esc]8;;$url$esc\\$text$esc]8;;$esc\\';
}
