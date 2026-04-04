## MonetDB/e embedded columnar database.
##
## Two-layer wrapper: ffi.nim (raw C bindings) + this file (idiomatic Nim API).
## All public boundaries return Choice[T].

{.push strictFuncs.}

import std/times
import basis/code/choice
import monetdb/ffi
import monetdb/types

export types
export choice

# =====================================================================================================================
# Connection
# =====================================================================================================================

proc connect*(path: string, memory_limit = 0, query_timeout = 0, session_timeout = 0, threads = 0): Connection {.raises: [].} =
  ## Create a new connection handle (does not open the database).
  Connection(
    db: nil,
    path: path,
    memory_limit: memory_limit,
    query_timeout: query_timeout,
    session_timeout: session_timeout,
    threads: threads,
  )

proc open*(c: Connection): Choice[void] {.raises: [].} =
  ## Open the database connection.
  var database: ffi.Database
  var options = ffi.Options(
    memorylimit: c.memory_limit.int32,
    querytimeout: c.query_timeout.int32,
    sessiontimeout: c.session_timeout.int32,
    nr_threads: c.threads.int32,
  )
  let code = ffi.open(database.addr, c.path.cstring, options.addr)
  if code == 0:
    {.cast(noSideEffect).}:
      c.db = database
    return good[void]()
  if code == -2:
    let msg = $ffi.error(database)
    discard ffi.close(database)
    return bad[void]("monetdb", msg)
  if code == -1:
    return bad[void]("monetdb", "allocation failed")
  bad[void]("monetdb", "unknown error (code " & $code & ")")

proc close*(c: Connection): Choice[void] {.raises: [].} =
  ## Close the database connection.
  if c.db.isNil:
    return good[void]()
  let code = ffi.close(c.db)
  if code != 0:
    return bad[void]("monetdb", "error closing database (code " & $code & ")")
  {.cast(noSideEffect).}:
    c.db = nil
  good[void]()

proc error*(c: Connection): string {.raises: [].} =
  ## Return the last error message, or empty string.
  let msg = ffi.error(c.db)
  if msg.isNil: "" else: $msg

# =====================================================================================================================
# Autocommit
# =====================================================================================================================

proc set_autocommit*(c: Connection, on: bool): Choice[void] {.raises: [].} =
  ## Enable or disable autocommit.
  check_error(ffi.set_autocommit(c.db, on.int32))

proc autocommit*(c: Connection): Choice[bool] {.raises: [].} =
  ## Return whether autocommit is enabled.
  var val: int32 = 0
  let msg = ffi.get_autocommit(c.db, val.addr)
  if not msg.isNil:
    return bad[bool]("monetdb", $msg)
  good(val.bool)

# =====================================================================================================================
# Transaction
# =====================================================================================================================

proc execute*(c: Connection, query: string): Choice[int64] {.raises: [].} =
  ## Execute a SQL statement. Returns number of affected rows.
  var rows: ffi.Count = 0
  let msg = ffi.query(c.db, query.cstring, nil, rows.addr)
  if not msg.isNil:
    return bad[int64]("monetdb", $msg)
  good(rows)

proc begin_transaction*(c: Connection): Choice[void] {.raises: [].} =
  ## Start a new transaction.
  let r = c.execute("START TRANSACTION")
  if r.is_bad:
    return bad[void]("monetdb", r.err.msg)
  good[void]()

proc in_transaction*(c: Connection): bool {.raises: [].} =
  ## Return whether a transaction is active.
  ffi.in_transaction(c.db).bool

proc commit*(c: Connection): Choice[void] {.raises: [].} =
  ## Commit the current transaction.
  let r = c.execute("COMMIT")
  if r.is_bad:
    return bad[void]("monetdb", r.err.msg)
  good[void]()

proc rollback*(c: Connection): Choice[void] {.raises: [].} =
  ## Rollback the current transaction.
  let r = c.execute("ROLLBACK")
  if r.is_bad:
    return bad[void]("monetdb", r.err.msg)
  good[void]()

# =====================================================================================================================
# Query
# =====================================================================================================================

proc query*(c: Connection, sql: string): Choice[tuple[result: ffi.PResult, rows: int64]] {.raises: [].} =
  ## Execute a query and return the result handle.
  var rp: ffi.PResult = nil
  var rows: ffi.Count = 0
  let msg = ffi.query(c.db, sql.cstring, rp.addr, rows.addr)
  if not msg.isNil:
    return bad[tuple[result: ffi.PResult, rows: int64]]("monetdb", $msg)
  good((result: rp, rows: rows))

proc fetch_column*(rp: ffi.PResult, index: int): Choice[ffi.PColumn] {.raises: [].} =
  ## Fetch a column from a query result by index.
  var col: ffi.PColumn
  let msg = ffi.result_fetch(rp, col.addr, index.csize_t)
  if not msg.isNil:
    return bad[ffi.PColumn]("monetdb", $msg)
  good(col)

proc cleanup*(c: Connection, rp: ffi.PResult): Choice[void] {.raises: [].} =
  ## Release a query result.
  check_error(ffi.cleanup_result(c.db, rp))

# =====================================================================================================================
# Dump
# =====================================================================================================================

proc dump_database*(c: Connection, backup_path: string): Choice[void] {.raises: [].} =
  ## Dump the entire database to a file.
  check_error(ffi.dump_database(c.db, backup_path.cstring))

proc dump_table*(c: Connection, table: string, backup_path: string, schema = "sys"): Choice[void] {.raises: [].} =
  ## Dump a single table to a file.
  check_error(ffi.dump_table(c.db, schema.cstring, table.cstring, backup_path.cstring))

# =====================================================================================================================
# Prepared statements
# =====================================================================================================================

proc prepare*(c: Connection, sql: string): Choice[ffi.PStatement] {.raises: [].} =
  ## Prepare a SQL statement.
  var stmt: ffi.PStatement
  let msg = ffi.prepare(c.db, sql.cstring, stmt.addr)
  if not msg.isNil:
    return bad[ffi.PStatement]("monetdb", $msg)
  good(stmt)

proc cleanup_statement*(c: Connection, stmt: ffi.PStatement): Choice[void] {.raises: [].} =
  ## Release a prepared statement.
  check_error(ffi.cleanup_statement(c.db, stmt))
