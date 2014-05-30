import perf;

import std.stdio;

void main(string[] args)
{
	FileHeader header;
	File f = File(args[1]);
	f.rawRead((cast(ubyte*) &header)[0 .. FileHeader.sizeof]);
	assert (header.magic == PERF_HEADER_VERSION_2);
	writeln("Header size: ", header.size);
	writeln("Header attr size: ", header.attr_size);
	writeln("attrs.offset: ", header.attrs.offset);
	writeln("attrs.size: ", header.attrs.size);
	writeln("data.offset: ", header.data.offset);
	writeln("data.size: ", header.data.size);
	writeln("header.event_types.offset: ", header.event_types.offset);
	writeln("header.event_types.size: ", header.event_types.size);
//	return;

	size_t nextOffset = header.data.offset;
	uint[PERF_RECORD_MAX] counts;
	foreach (i; 0 .. header.data.size)
	{
		f.seek(nextOffset);
		EventHeader e;
		f.rawRead((cast(ubyte*) &e)[0 .. EventHeader.sizeof]);
		switch (e.type)
		{
		case PERF_RECORD_MMAP:
		case PERF_RECORD_LOST:
		case PERF_RECORD_COMM:
		case PERF_RECORD_EXIT:
		case PERF_RECORD_THROTTLE:
		case PERF_RECORD_UNTHROTTLE:
		case PERF_RECORD_FORK:
		case PERF_RECORD_READ:
		case PERF_RECORD_SAMPLE:
		case PERF_RECORD_MMAP2:
		case PERF_RECORD_MAX:
			counts[e.type - 1]++;
		default:
			break;
		}
		nextOffset += e.size;
	}
	writeln("mmap: ", counts[PERF_RECORD_MMAP - 1]);
	writeln("lost: ", counts[PERF_RECORD_LOST - 1]);
	writeln("comm: ", counts[PERF_RECORD_COMM - 1]);
	writeln("exit: ", counts[PERF_RECORD_EXIT - 1]);
	writeln("throttle: ", counts[PERF_RECORD_THROTTLE - 1]);
	writeln("unthrottle: ", counts[PERF_RECORD_UNTHROTTLE - 1]);
	writeln("fork: ", counts[PERF_RECORD_FORK - 1]);
	writeln("read: ", counts[PERF_RECORD_READ - 1]);
	writeln("sample: ", counts[PERF_RECORD_SAMPLE - 1]);
	writeln("mmap2: ", counts[PERF_RECORD_MMAP2 - 1]);
}
