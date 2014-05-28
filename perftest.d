import perf;

import std.stdio;

union headermagic
{
	ubyte[8] bytes;
	ulong number;
}

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
	writeln("header.event_types.offset: ", header.event_types.offset);
	writeln("header.event_types.size: ", header.event_types.size);
}
