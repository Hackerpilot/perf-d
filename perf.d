module perf;

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

enum PERF_SAMPLE_MAX_SIZE = 1 << 16;

enum HeaderVersion {
	PERF_HEADER_VERSION_1,
	PERF_HEADER_VERSION_2,
}

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

//struct TraceEvent
//{
//	PEvent* pevent;
//	PluginList* plugin_list;
//}

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

//struct Evlist
//{
//	ListHead entries;
//	HListHead[PERF_EVLIST__HLIST_SIZE] heads;
//	int nr_entries;
//	int nr_groups;
//	int nr_fds;
//	int nr_mmaps;
//	size_t mmap_len;
//	int id_pos;
//	int is_pos;
//	ulong combined_sample_type;
//	struct Workload
//	{
//		int	cork_fd;
//		pid_t	pid;
//	}
//	bool		 overwrite;
//	MMap* mmap;
//	Pollfd* pollfd;
//	ThreadMap* threads;
//	CPUMap* cpus;
//	Evsel* selected;
//}


struct EvselStrHandler
{
	const(char)* name;
	void* handler;
}
