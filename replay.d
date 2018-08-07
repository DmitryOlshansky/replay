/**
	replay - utility to pipe output from logs 
	honoring the timings and optionally
	scaling the speed by provided amount

	---
	
	# For instance - pipe at half the speed:
	replay -s 0.5 < log.log | ./your-log-processor

	# Start at +1.0 and stay 1.0 seconds ahead
	# of timestamps in log (burst at start!)
	replay --handicap 1.0 < log.log | ...

	# no handicap and 2.5x faster then events really accured
	replay -c 0 -s 2.5 < log.log | ...

	---
	
	TODO: 
	1. add buffering amount in seconds to avoid 'handicap' hack.
	2. more accurate timing
	3. Windows / xBSD support

*/
import core.sys.linux.time;
import std.getopt, std.exception,
	std.regex, std.stdio, std.conv;

double toSeconds(C)(C captures) {
	int year = captures["YYYY"].to!int;
	int month = captures["MM"].to!int;
	int day = captures["DD"].to!int;
	int hours = captures["HH"].to!int;
	int minutes = captures["mm"].to!int;
	int seconds = captures["SS"].to!int;

	return 0;
}

// simple but not accurate
timespec toTimeSpec(double seconds) {
	timespec ts;
	ts.tv_sec = cast(long)seconds;
	double frac = seconds - cast(long)seconds;
	ts.tv_nsec = cast(long)(frac*1e9);
	return ts;
}

auto compileFromPattern(string timePattern) {
	string regexPattern;
	bool inSubPattern;
	foreach(dchar c; timePattern)  {
	switch(c) {
		case 'Y', 'M', 'D', 'H', 'S', 'm':
			if (inSubPattern)
				regexPattern ~= `\d`;
			else {
				inSubPattern = true;
				regexPattern ~= `(\d`; //open group
			}
		default:
			if (inSubPattern) {
				// close on first not well-known char
				// sub-pattern is closed
				inSubPattern = false;
				regexPattern ~= ')';
			}
			//TODO: escape special symbols!
			regexPattern ~= c;

	}
	debug writeln("REGEX: ", regexPattern);
}

int main(string[] args) {
	double speed = 1.0;
	// amount of seconds to stay ahead of timing
	// basically it must be enough to read line and write line
	double handicap = 0.001;
	string pattern = "YYYY-MM-DD HH:mm:SS";

	getopt(
		args,
		"speed|s", 
		"Speed measured in times, floating-point value. 1.0 is same speed.",
		&speed,
		
		"handicap|c", 
		"Amount of time (seconds, floating-point) to stay ahead of timing", 
		&handicap,

		"pattern|p",
		"Pattern for timestamp following the basics of strftime",
		&pattern
	);
	enforce(speed > 0.0, "speed must be greater then 0.0");
	enforce(handicap >= 0.0, "handicap must be greater or equal 0.0");
	auto timeRe = compileFromPattern(pattern);

	double last = 0; // last visited timestamp
	// line is mutable and buffer is extended as needed ...
	foreach(line; stdin.byLine) {
		auto m = matchFirst(line, timeRe);
		if(m) {
			double time = m.toSeconds;
			double delta = time - last;
			// insert delay to keep the timing
			// mostly in sync 
			// this "accuracy" is fine for us now
			double sleep = (delta - handicap) / speed;
			if (sleep > 1e8) {
				timespec spec = toTimeSpec(sleep);
				nanosleep(&spec, &spec);
				//TODO: check if EINTR (to continue pause) or other error 
			}
			last = time;
		}
		stdout.write(line);
	}
	return 0;
}
