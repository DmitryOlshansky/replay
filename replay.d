import core.sys.linux.time;
import std.getopt, std.regex, std.stdio, std.datetime;

long getnanos(C)(in C captures) {
	//TODO: assemble time from components
	return 0;
}

timespec toTimeSpec(double seconds)
{
	timespec ts;
	//TODO:...
	return ts;
}

int main(string[] args) {
	double speed = 1.0;
	// amount of seconds to stay ahead of timing
	// basically it must be enough to read line and write line
	double handicap = 0.001;
	string pattern = "yyyy-mm-dd HH:MM:SS";

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

	auto r = regex(".TODO.");
	long last = 0;
	foreach(line; stdin.byLine) {
		// line is mutable and extended as needed...
		auto m = matchFirst(line, r);
		if(m) {
			long time = getnanos(m);
			long delta = time - last;
			// insert delay to keep the timing mostly in sync
			double sleep = (delta - handicap) / speed;
			timespec wanted = toTimeSpec(sleep);
			timespec rem;
			nanosleep(&wanted, &rem);
			//TODO: check reminder(!) 
			last = time;
		}
		stdout.write(line);
	}
	return 0;
}
