#!/bin/bash
# This is designed to be able to be run from git bash
# You therefore should install git bash, Visual Studio 2015, and cmake

ROCKSDBVERSION=c6fedf2bf
GFLAGSVERSION=9db82895
SNAPPYVERSION=37aafc9e

ROCKSDBREMOTE=https://github.com/warrenfalk/rocksdb
GFLAGSREMOTE=https://github.com/warrenfalk/gflags
SNAPPYREMOTE=https://github.com/warrenfalk/snappy

CONCURRENCY=8

fail() {
	>&2 echo -e "\033[1;31m$1\033[0m"
	exit 1
}

warn() {
	>&2 echo -e "\033[1;33m$1\033[0m"
}

run_rocksdb_test() {
	NAME=$1
	echo "Running test \"${NAME}\":"
	cmd //c "build\\Debug\\${NAME}.exe" || fail "Test failed"
}

checkout() {
	NAME="$1"
	REMOTE="$2"
	VERSION="$3"
	FETCHREF="$4"
	test -d .git || git init
	test -d .git || fail "unable to initialize $NAME repository"
	git fetch "$REMOTE" "${FETCHREF}" || fail "Unable to fetch latest $NAME"
	git checkout "$VERSION" || fail "Unable to checkout $NAME version ${VERSION}"
}

# Make sure git is installed
hash git 2> /dev/null || { fail "Build requires git"; }
test -z "$WindowsSdkDir" && fail "This must be run from a build environment such as the Developer Command Prompt"

BASEDIR=$(dirname "$0")
BASEDIRWIN=$(cd "${BASEDIR}" && pwd -W)

mkdir -p snappy || fail "unable to create snappy directory"
(cd snappy && {
	checkout "snappy" "$SNAPPYREMOTE" "$SNAPPYVERSION" "cmake"
	mkdir -p build
	(cd build && {
		cmake -G "Visual Studio 14 2015 Win64" .. || fail "Running cmake on snappy failed"
	}) || fail "cmake build generation failed"
	test -z "$RUNTESTS" || {
		cmd //c "msbuild build/snappy.sln /p:Configuration=Debug /m:$CONCURRENCY" || fail "Build of snappy (debug config) failed"
	}
	cmd //c "msbuild build/snappy.sln /p:Configuration=Release /m:$CONCURRENCY" || fail "Build of snappy failed"
}) || fail "Snappy build failed"


mkdir -p gflags || fail "unable to create gflags directory"
(cd gflags && {
	checkout "gflags" "$GFLAGSREMOTE" "$GFLAGSVERSION" "master"
	mkdir -p build
	(cd build && {
		cmake -G "Visual Studio 14 2015 Win64" .. || fail "Running cmake failed"
	}) || fail "cmake build generation failed"
	test -z "$RUNTESTS" || {
		cmd //c "msbuild build/gflags.sln /p:Configuration=Debug /m:$CONCURRENCY" || fail "Build of gflags (debug config) failed"
	}
	cmd //c "msbuild build/gflags.sln /p:Configuration=Release /m:$CONCURRENCY" || fail "Build of gflags failed"
}) || fail "GFlags build failed"


mkdir -p rocksdb || fail "unable to create rocksdb directory"
(cd rocksdb && {
	checkout "rocksdb" "$ROCKSDBREMOTE" "$ROCKSDBVERSION" "wf_win_master"
	git checkout -- thirdparty.inc
	patch -N < ../rocksdb.thirdparty.inc.patch || warn "Patching of thirdparty.inc failed"
	rm -f thirdparty.inc.rej thirdparty.inc.orig
	mkdir -p build
	(cd build && {
		cmake -G "Visual Studio 14 2015 Win64" -DOPTDBG=1 -DGFLAGS=1 -DSNAPPY=1 .. || fail "Running cmake failed"
	}) || fail "cmake build generation failed"

	export TEST_TMPDIR=$(cmd //c "echo %TMP%")

	# TODO: build debug version first and run tests
	test -z "$RUNTESTS" || {
		cmd //c "msbuild build/rocksdb.sln /p:Configuration=Debug /m:$CONCURRENCY" || fail "Rocksdb debug build failed"
		run_rocksdb_test db_test
		run_rocksdb_test db_iter_test
		run_rocksdb_test db_log_iter_test
		run_rocksdb_test db_compaction_filter_test
		run_rocksdb_test db_compaction_test
		run_rocksdb_test db_dynamic_level_test
		run_rocksdb_test db_inplace_update_test
		run_rocksdb_test db_tailing_iter_test
		run_rocksdb_test db_universal_compaction_test
		run_rocksdb_test db_wal_test
		run_rocksdb_test db_table_properties_test
		run_rocksdb_test block_hash_index_test
		run_rocksdb_test autovector_test
		run_rocksdb_test column_family_test
		run_rocksdb_test table_properties_collector_test
		run_rocksdb_test arena_test
		run_rocksdb_test auto_roll_logger_test
		run_rocksdb_test block_test
		run_rocksdb_test bloom_test
		run_rocksdb_test dynamic_bloom_test
		run_rocksdb_test c_test
		run_rocksdb_test cache_test
		run_rocksdb_test checkpoint_test
		run_rocksdb_test coding_test
		run_rocksdb_test corruption_test
		run_rocksdb_test crc32c_test
		run_rocksdb_test slice_transform_test
		run_rocksdb_test dbformat_test
		run_rocksdb_test env_test
		run_rocksdb_test fault_injection_test
		run_rocksdb_test filelock_test
		run_rocksdb_test filename_test
		run_rocksdb_test file_reader_writer_test
		run_rocksdb_test block_based_filter_block_test
		run_rocksdb_test full_filter_block_test
		run_rocksdb_test histogram_test
		run_rocksdb_test inlineskiplist_test
		run_rocksdb_test log_test
		run_rocksdb_test manual_compaction_test
		run_rocksdb_test memenv_test
		run_rocksdb_test mock_env_test
		run_rocksdb_test memtable_list_test
		run_rocksdb_test merge_helper_test
		run_rocksdb_test memory_test
		run_rocksdb_test merge_test
		run_rocksdb_test merger_test
		run_rocksdb_test options_file_test
		run_rocksdb_test redis_lists_test
		run_rocksdb_test reduce_levels_test
		run_rocksdb_test plain_table_db_test
		run_rocksdb_test comparator_db_test
		run_rocksdb_test prefix_test
		run_rocksdb_test skiplist_test
		run_rocksdb_test stringappend_test
		run_rocksdb_test ttl_test
		run_rocksdb_test backupable_db_test
		run_rocksdb_test document_db_test
		run_rocksdb_test json_document_test
		run_rocksdb_test spatial_db_test
		run_rocksdb_test version_edit_test
		run_rocksdb_test version_set_test
		run_rocksdb_test compaction_picker_test
		run_rocksdb_test version_builder_test
		run_rocksdb_test file_indexer_test
		run_rocksdb_test write_batch_test
		run_rocksdb_test write_batch_with_index_test
		run_rocksdb_test write_controller_test
		run_rocksdb_test deletefile_test
		run_rocksdb_test table_test
		run_rocksdb_test thread_local_test
		run_rocksdb_test geodb_test
		run_rocksdb_test rate_limiter_test
		run_rocksdb_test delete_scheduler_test
		run_rocksdb_test options_test
		run_rocksdb_test options_util_test
		run_rocksdb_test event_logger_test
		run_rocksdb_test cuckoo_table_builder_test
		run_rocksdb_test cuckoo_table_reader_test
		run_rocksdb_test cuckoo_table_db_test
		run_rocksdb_test flush_job_test
		run_rocksdb_test wal_manager_test
		run_rocksdb_test listener_test
		run_rocksdb_test compaction_iterator_test
		run_rocksdb_test compaction_job_test
		run_rocksdb_test thread_list_test
		run_rocksdb_test sst_dump_test
		run_rocksdb_test compact_files_test
		run_rocksdb_test perf_context_test
		run_rocksdb_test optimistic_transaction_test
		run_rocksdb_test write_callback_test
		run_rocksdb_test heap_test
		run_rocksdb_test compact_on_deletion_collector_test
		run_rocksdb_test compaction_job_stats_test
		run_rocksdb_test transaction_test
		run_rocksdb_test ldb_cmd_test
	}
	cmd //c "msbuild build/rocksdb.sln /p:Configuration=Release /m:$CONCURRENCY" || fail "Rocksdb release build failed"
	git checkout -- thirdparty.inc
	mkdir -p ../../native/amd64 && cp -v ./build/Release/rocksdb.dll ../../native/amd64/librocksdb.dll
}) || fail "rocksdb build failed"
