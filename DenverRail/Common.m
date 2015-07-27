void TLog(const char *file, int line, NSString *format, ...) {
  va_list args;
  NSString *logString = nil;
  
  va_start(args, format);
  NSLogv(format, args);
  va_end(args);
  
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
  
  logString = [NSString stringWithFormat:@"%@ %s:%d %@",[dateFormatter stringFromDate:[NSDate date]], file, line, logString];
  
  puts([logString UTF8String]);
}
