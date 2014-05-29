module perf;

alias pid_t = int;

/**
 * Magic number for version 1 of the Perf file format
 */
enum ulong PERF_HEADER_VERSION_1 =
	  (cast(ulong) 'P')
	| (cast(ulong) 'E') << 8
	| (cast(ulong) 'R') << 16
	| (cast(ulong) 'F') << 24
	| (cast(ulong) 'F') << 32
	| (cast(ulong) 'I') << 40
	| (cast(ulong) 'L') << 48
	| (cast(ulong) 'E') << 56;

/**
 * Magic number for version 2 of the Perf file format
 */
enum ulong PERF_HEADER_VERSION_2 =
	  (cast(ulong) 'P')
	| (cast(ulong) 'E') << 8
	| (cast(ulong) 'R') << 16
	| (cast(ulong) 'F') << 24
	| (cast(ulong) 'I') << 32
	| (cast(ulong) 'L') << 40
	| (cast(ulong) 'E') << 48
	| (cast(ulong) '2') << 56;

enum PERF_EVLIST__HLIST_BITS = 8;
enum PERF_EVLIST__HLIST_SIZE = (1 << PERF_EVLIST__HLIST_BITS);

enum
{
	PERF_SAMPLE_IP				= 1U << 0,
	PERF_SAMPLE_TID				= 1U << 1,
	PERF_SAMPLE_TIME			= 1U << 2,
	PERF_SAMPLE_ADDR			= 1U << 3,
	PERF_SAMPLE_READ			= 1U << 4,
	PERF_SAMPLE_CALLCHAIN			= 1U << 5,
	PERF_SAMPLE_ID				= 1U << 6,
	PERF_SAMPLE_CPU				= 1U << 7,
	PERF_SAMPLE_PERIOD			= 1U << 8,
	PERF_SAMPLE_STREAM_ID			= 1U << 9,
	PERF_SAMPLE_RAW				= 1U << 10,
	PERF_SAMPLE_BRANCH_STACK		= 1U << 11,
	PERF_SAMPLE_REGS_USER			= 1U << 12,
	PERF_SAMPLE_STACK_USER			= 1U << 13,
	PERF_SAMPLE_WEIGHT			= 1U << 14,
	PERF_SAMPLE_DATA_SRC			= 1U << 15,
	PERF_SAMPLE_IDENTIFIER			= 1U << 16,
	PERF_SAMPLE_TRANSACTION			= 1U << 17,
	PERF_SAMPLE_MAX = 1U << 18,		/* non-ABI */
}

enum PERF_SAMPLE_MASK =
	  PERF_SAMPLE_IP
	| PERF_SAMPLE_TID
	| PERF_SAMPLE_TIME
	| PERF_SAMPLE_ADDR
	| PERF_SAMPLE_ID
	| PERF_SAMPLE_STREAM_ID
	| PERF_SAMPLE_CPU
	| PERF_SAMPLE_PERIOD
	| PERF_SAMPLE_IDENTIFIER;

enum PERF_SAMPLE_MAX_SIZE = 1 << 16;

enum {
	HEADER_RESERVED		= 0,	/* always cleared */
	HEADER_FIRST_FEATURE	= 1,
	HEADER_TRACING_DATA	= 1,
	HEADER_BUILD_ID,

	HEADER_HOSTNAME,
	HEADER_OSRELEASE,
	HEADER_VERSION,
	HEADER_ARCH,
	HEADER_NRCPUS,
	HEADER_CPUDESC,
	HEADER_CPUID,
	HEADER_TOTAL_MEM,
	HEADER_CMDLINE,
	HEADER_EVENT_DESC,
	HEADER_CPU_TOPOLOGY,
	HEADER_NUMA_TOPOLOGY,
	HEADER_BRANCH_STACK,
	HEADER_PMU_MAPPINGS,
	HEADER_GROUP_DESC,
	HEADER_LAST_FEATURE,
	HEADER_FEAT_BITS	= 256,
}

struct EventHeader {
	uint type;
	ushort misc;
	ushort size;
}

enum HeaderVersion {
	PERF_HEADER_VERSION_1,
	PERF_HEADER_VERSION_2,
}

enum
{
	PERF_RECORD_MMAP			= 1,
	PERF_RECORD_LOST			= 2,
	PERF_RECORD_COMM			= 3,
	PERF_RECORD_EXIT			= 4,
	PERF_RECORD_THROTTLE			= 5,
	PERF_RECORD_UNTHROTTLE			= 6,
	PERF_RECORD_FORK			= 7,
	PERF_RECORD_READ			= 8,
	PERF_RECORD_SAMPLE			= 9,
	PERF_RECORD_MMAP2			= 10,
	PERF_RECORD_MAX,			/* non-ABI */
}

enum PATH_MAX = 4096;

struct FileSection {
	ulong offset;
	ulong size;
}

struct FileHeader {
	ulong magic;
	ulong size;
	ulong attr_size;
	FileSection	attrs;
	FileSection data;
	FileSection event_types;
	ulong[HEADER_FEAT_BITS] adds_features;
}

struct Header {
	HeaderVersion _version;
	bool needs_swap;
	ulong data_offset;
	ulong data_size;
	ulong feat_offset;
	ulong[HEADER_FEAT_BITS] adds_features;
	SessionEnv env;
}

union Event {
	EventHeader	header;
	MMapEvent mmap;
	MMap2Event mmap2;
	CommEvent comm;
	ForkEvent fork;
	LostEvent lost;
	ReadEvent read;
	ThrottleEvent throttle;
	SampleEvent sample;
	AttrEvent attr;
	EventTypeEvent event_type;
	TracingDataEvent tracing_data;
	BuildIdEvent build_id;
}

struct SampleEvent {
	EventHeader header;
	ubyte* array;
}

struct TracingDataEvent {
	EventHeader header;
	uint size;
}

struct EventTypeEvent {
	EventHeader header;
	TraceEventType event_type;
}

struct EventAttr {
	uint			type;
	uint			size;
	ulong			config;
	union {
		ulong		sample_period;
		ulong		sample_freq;
	}
	ulong			sample_type;
	ulong			read_format;
	import std.bitmanip;
	mixin(bitfields!(
		ulong, "disabled", 1,
		ulong, "inherit", 1,
		ulong, "pinned", 1,
		ulong, "exclusive", 1,
		ulong, "exclude_user", 1,
		ulong, "exclude_kernel", 1,
		ulong, "exclude_hv", 1,
		ulong, "exclude_idle", 1,
		ulong, "mmap", 1,
		ulong, "comm", 1,
		ulong, "freq", 1,
		ulong, "inherit_stat", 1,
		ulong, "enable_on_exec" , 1,
		ulong, "task", 1,
		ulong, "watermark", 1,
		ulong, "precise_ip", 2,
		ulong, "mmap_data", 1,
		ulong, "sample_id_all", 1,
		ulong, "exclude_host", 1,
		ulong, "exclude_guest", 1,
		ulong, "exclude_callchain_kernel", 1,
		ulong, "exclude_callchain_user", 1,
		ulong, "mmap2",  1,
		ulong, "__reserved_1", 40
	));
	union {
		uint		wakeup_events;
		uint		wakeup_watermark;
	}
	uint			bp_type;
	union {
		ulong		bp_addr;
		ulong		config1;
	}
	union {
		ulong		bp_len;
		ulong		config2;
	}
	ulong	branch_sample_type;
	ulong	sample_regs_user;
	uint	sample_stack_user;
	uint	__reserved_2;
}

struct AttrEvent {
	EventHeader header;
	EventAttr attr;
	ulong* id;
}

struct MMapEvent {
	EventHeader header;
	uint pid;
	uint tid;
	ulong start;
	ulong len;
	ulong pgoff;
	char[PATH_MAX] filename;
}

struct MMap2Event {
	EventHeader header;
	uint pid;
	uint tid;
	ulong start;
	ulong len;
	ulong pgoff;
	uint maj;
	uint min;
	ulong ino;
	ulong ino_generation;
	char[PATH_MAX] filename;
}

struct CommEvent {
	EventHeader header;
	uint pid;
	uint tid;
	char[16] comm;
}

struct ForkEvent {
	EventHeader header;
	uint pid;
	uint ppid;
	uint tid;
	uint ptid;
	ulong time;
}

struct LostEvent {
	EventHeader header;
	ulong id;
	ulong lost;
}

struct ReadEvent {
	EventHeader header;
	uint pid;
	uint tid;
	ulong value;
	ulong time_enabled;
	ulong time_running;
	ulong id;
}

struct ThrottleEvent {
	EventHeader header;
	ulong time;
	ulong id;
	ulong stream_id;
}

struct SampleReadValue {
	ulong value;
	ulong id;
}

struct SampleRead {
	ulong time_enabled;
	ulong time_running;
	union {
		struct Group {
			ulong nr;
			SampleReadValue* values;
		}
		SampleReadValue one;
	}
}

enum BUILD_ID_SIZE = 20;
size_t PERF_ALIGN(size_t x, size_t a) { return (x + (a - 1)) & (~(a - 1)); }

struct BuildIdEvent {
	EventHeader header;
	pid_t pid;
	ubyte[PERF_ALIGN(BUILD_ID_SIZE, ulong.sizeof)] build_id;
	char* filename;
}

struct RegsDump {
	ulong abi;
	ulong* regs;
}

struct IPCallchain {
	ulong nr;
	ulong[0] ips;
}

struct BranchStack {
	ulong nr;
	BranchEntry[0] entries;
}

struct BranchFlags {
	import std.bitmanip;
	mixin(bitfields!(
		ulong, "mispred", 1,
		ulong, "predicted", 1,
		ulong, "in_tx", 1,
		ulong, "abort", 1,
		ulong, "reserved", 60
	));
}

struct BranchEntry {
	ulong from;
	ulong to;
	BranchFlags flags;
}

struct StackDump {
	ushort offset;
	ulong size;
	char *data;
}

struct Sample {
	ulong ip;
	uint pid, tid;
	ulong time;
	ulong addr;
	ulong id;
	ulong stream_id;
	ulong period;
	ulong weight;
	ulong transaction;
	uint cpu;
	uint raw_size;
	ulong data_src;
	void* raw_data;
	IPCallchain* callchain;
	BranchStack* branch_stack;
	RegsDump  user_regs;
	StackDump user_stack;
	SampleRead read;
}

struct TraceEventType {
	ulong event_id;
	char[64] name;
}

struct MMap
{
	void* base;
	int mask;
	uint prev;
	char[PERF_SAMPLE_MAX_SIZE] event_copy;
}

struct SessionEnv {
	char			*hostname;
	char			*os_release;
	char			*_version;
	char			*arch;
	int			nr_cpus_online;
	int			nr_cpus_avail;
	char			*cpu_desc;
	char			*cpuid;
	ulong	total_mem;

	int			nr_cmdline;
	int			nr_sibling_cores;
	int			nr_sibling_threads;
	int			nr_numa_nodes;
	int			nr_pmu_mappings;
	int			nr_groups;
	char			*cmdline;
	char			*sibling_cores;
	char			*sibling_threads;
	char			*numa_nodes;
	char			*pmu_mappings;
}

enum DataMode
{
	PERF_DATA_MODE_WRITE,
	PERF_DATA_MODE_READ,
}

struct DataFile
{
	const(char)* path;
	int fd;
	bool is_pipe;
	bool force;
	ulong size;
	DataMode mode;
}

struct EvselStrHandler
{
	const(char)* name;
	void* handler;
}
