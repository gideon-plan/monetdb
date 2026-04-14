## MonetDB/e C FFI bindings.
## Dynamic link to libmonetdbe.so.

{.experimental: "strict_funcs".}

{.pragma: mdb_hdr, header: "/usr/include/monetdb/monetdbe.h".}
{.pragma: mdb_lib, dynlib: "libmonetdbe.so".}

type
  Types* {.size: sizeof(int32).} = enum
    monetdbe_bool
    monetdbe_int8_t
    monetdbe_int16_t
    monetdbe_int32_t
    monetdbe_int64_t
    monetdbe_size_t
    monetdbe_int128_t
    monetdbe_float
    monetdbe_double
    monetdbe_str
    monetdbe_blob
    monetdbe_date
    monetdbe_time
    monetdbe_timestamp
    monetdbe_type_unknown

  Count* {.bycopy, mdb_hdr, importc: "monetdbe_cnt".} = int64

  Date* {.bycopy, mdb_hdr, importc: "monetdbe_data_date".} = object
    day*: uint8
    month*: uint8
    year*: cshort

  Time* {.bycopy, mdb_hdr, importc: "monetdbe_data_time".} = object
    ms*: cuint
    seconds*: uint8
    minutes*: uint8
    hours*: uint8

  Timestamp* {.bycopy, mdb_hdr, importc: "monetdbe_data_timestamp".} = object
    date*: Date
    time*: Time

  Blob* {.bycopy, mdb_hdr, importc: "monetdbe_data_blob".} = object
    size*: csize_t
    data*: cstring

  TColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column".} = object
    `type`*: Types
    data*: pointer
    count*: csize_t
    name*: cstring

  PColumn* = ptr TColumn

  TStatement* {.bycopy, mdb_hdr, importc: "monetdbe_statement".} = object
    nparam*: csize_t
    `type`*: ptr Types

  PStatement* = ptr TStatement

  TResult* {.bycopy, mdb_hdr, importc: "monetdbe_result".} = object
    nrows*: Count
    ncols*: csize_t
    name*: cstring
    last_id*: Count

  PResult* = ptr TResult

  Database* {.mdb_hdr, importc: "monetdbe_database".} = pointer

  Options* {.bycopy, mdb_hdr, importc: "monetdbe_options".} = object
    memorylimit*: int32
    querytimeout*: int32
    sessiontimeout*: int32
    nr_threads*: int32

  # Typed column structs for field extraction.
  BoolColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_bool".} = object
    `type`*: Types
    data*: ptr int8
    count*: uint
    name*: cstring
    null_value*: int8
    scale*: cdouble
    is_null*: proc(value: ptr int8): int32 {.cdecl.}

  Int8Column* {.bycopy, mdb_hdr, importc: "monetdbe_column_int8_t".} = object
    `type`*: Types
    data*: ptr int8
    count*: uint
    name*: cstring
    null_value*: int8
    scale*: cdouble
    is_null*: proc(value: ptr int8): int32 {.cdecl.}

  Int16Column* {.bycopy, mdb_hdr, importc: "monetdbe_column_int16_t".} = object
    `type`*: Types
    data*: ptr int16
    count*: uint
    name*: cstring
    null_value*: int16
    scale*: cdouble
    is_null*: proc(value: ptr int16): int32 {.cdecl.}

  Int32Column* {.bycopy, mdb_hdr, importc: "monetdbe_column_int32_t".} = object
    `type`*: Types
    data*: ptr int32
    count*: uint
    name*: cstring
    null_value*: int32
    scale*: cdouble
    is_null*: proc(value: ptr int32): int32 {.cdecl.}

  Int64Column* {.bycopy, mdb_hdr, importc: "monetdbe_column_int64_t".} = object
    `type`*: Types
    data*: ptr int64
    count*: uint
    name*: cstring
    null_value*: int64
    scale*: cdouble
    is_null*: proc(value: ptr int64): int32 {.cdecl.}

  SizeColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_size_t".} = object
    `type`*: Types
    data*: ptr csize_t
    count*: uint
    name*: cstring
    null_value*: uint
    scale*: cdouble
    is_null*: proc(value: ptr csize_t): int32 {.cdecl.}

  FloatColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_float".} = object
    `type`*: Types
    data*: ptr cfloat
    count*: uint
    name*: cstring
    null_value*: cfloat
    scale*: cdouble
    is_null*: proc(value: ptr cfloat): int32 {.cdecl.}

  DoubleColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_double".} = object
    `type`*: Types
    data*: ptr cdouble
    count*: uint
    name*: cstring
    null_value*: cdouble
    scale*: cdouble
    is_null*: proc(value: ptr cdouble): int32 {.cdecl.}

  StringColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_str".} = object
    `type`*: Types
    data*: ptr cstring
    count*: uint
    name*: cstring
    null_value*: cstring
    scale*: cdouble
    is_null*: proc(value: ptr cstring): int32 {.cdecl.}

  BlobColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_blob".} = object
    `type`*: Types
    data*: ptr Blob
    count*: uint
    name*: cstring
    null_value*: Blob
    scale*: cdouble
    is_null*: proc(value: ptr Blob): int32 {.cdecl.}

  DateColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_date".} = object
    `type`*: Types
    data*: ptr Date
    count*: uint
    name*: cstring
    null_value*: Date
    scale*: cdouble
    is_null*: proc(value: ptr Date): int32 {.cdecl.}

  TimeColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_time".} = object
    `type`*: Types
    data*: ptr Time
    count*: uint
    name*: cstring
    null_value*: Time
    scale*: cdouble
    is_null*: proc(value: ptr Time): int32 {.cdecl.}

  TimestampColumn* {.bycopy, mdb_hdr, importc: "monetdbe_column_timestamp".} = object
    `type`*: Types
    data*: ptr Timestamp
    count*: uint
    name*: cstring
    null_value*: Timestamp
    scale*: cdouble
    is_null*: proc(value: ptr Timestamp): int32 {.cdecl.}

{.push cdecl.}

# Database lifecycle.
proc open*(db: ptr Database, url: cstring, opts: ptr Options): int32 {.importc: "monetdbe_open", mdb_lib.}
proc close*(db: Database): int32 {.importc: "monetdbe_close", mdb_lib.}
proc error*(db: Database): cstring {.importc: "monetdbe_error", mdb_lib.}

# Autocommit.
proc get_autocommit*(db: Database, result: ptr int32): cstring {.importc: "monetdbe_get_autocommit", mdb_lib.}
proc set_autocommit*(db: Database, value: int32): cstring {.importc: "monetdbe_set_autocommit", mdb_lib.}

# Transactions.
proc in_transaction*(db: Database): int32 {.importc: "monetdbe_in_transaction", mdb_lib.}

# Query execution.
proc query*(db: Database, query: cstring, result: ptr PResult, affected_rows: ptr Count): cstring {.importc: "monetdbe_query", mdb_lib.}
proc result_fetch*(mres: PResult, res: ptr PColumn, column_index: csize_t): cstring {.importc: "monetdbe_result_fetch", mdb_lib.}
proc cleanup_result*(db: Database, result: PResult): cstring {.importc: "monetdbe_cleanup_result", mdb_lib.}

# Bulk append.
proc append*(db: Database, schema, table: cstring, input: ptr PColumn, column_count: csize_t): cstring {.importc: "monetdbe_append", mdb_lib.}

# Null sentinel.
proc null*(db: Database, t: Types): pointer {.importc: "monetdbe_null", mdb_lib.}

# Schema introspection.
proc get_columns*(db: Database, schema, table: cstring, column_count: ptr csize_t, column_names: ptr cstring, column_types: ptr ptr int32): cstring {.importc: "monetdbe_get_columns", mdb_lib.}

# Dump.
proc dump_database*(db: Database, backup: cstring): cstring {.importc: "monetdbe_dump_database", mdb_lib.}
proc dump_table*(db: Database, schema, table, backup: cstring): cstring {.importc: "monetdbe_dump_table", mdb_lib.}

# Prepared statements.
proc prepare*(db: Database, query: cstring, stmt: ptr PStatement): cstring {.importc: "monetdbe_prepare", mdb_lib.}
proc bind_param*(stmt: PStatement, data: pointer, parameter_nr: csize_t): cstring {.importc: "monetdbe_bind", mdb_lib.}
proc execute*(stmt: PStatement, result: ptr PResult, affected_rows: ptr Count): cstring {.importc: "monetdbe_execute", mdb_lib.}
proc cleanup_statement*(db: Database, stmt: PStatement): cstring {.importc: "monetdbe_cleanup_statement", mdb_lib.}

{.pop.} # cdecl
