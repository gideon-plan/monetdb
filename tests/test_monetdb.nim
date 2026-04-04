## MonetDB/e integration tests.
## Requires libmonetdbe.so installed.

{.push strictFuncs.}

import std/unittest
import basis/code/choice
import monetdb

suite "monetdb connection":
  test "connect and open in-memory":
    let c = connect(":memory:")
    let r = c.open()
    check r.is_good
    let cl = c.close()
    check cl.is_good

  test "open bad path returns bad":
    let c = connect("/nonexistent/path/that/cannot/exist")
    let r = c.open()
    check r.is_bad

  test "close idempotent on nil db":
    let c = connect(":memory:")
    let r = c.close()
    check r.is_good

suite "monetdb execute":
  var c: Connection

  setup:
    c = connect(":memory:")
    discard c.open()

  teardown:
    discard c.close()

  test "create table and insert":
    let r1 = c.execute("CREATE TABLE test (id INT, name VARCHAR(100))")
    check r1.is_good
    let r2 = c.execute("INSERT INTO test VALUES (1, 'alice')")
    check r2.is_good
    check r2.val == 1

  test "query returns result":
    discard c.execute("CREATE TABLE q (x INT)")
    discard c.execute("INSERT INTO q VALUES (42)")
    let r = c.query("SELECT x FROM q")
    check r.is_good
    check r.val.rows == 1
    discard c.cleanup(r.val.result)

  test "bad sql returns bad":
    let r = c.execute("NOT VALID SQL")
    check r.is_bad

suite "monetdb transactions":
  var c: Connection

  setup:
    c = connect(":memory:")
    discard c.open()
    discard c.set_autocommit(false)

  teardown:
    discard c.close()

  test "begin and commit":
    let b = c.begin_transaction()
    check b.is_good
    check c.in_transaction
    discard c.execute("CREATE TABLE tx (v INT)")
    let cm = c.commit()
    check cm.is_good

  test "begin and rollback":
    let b = c.begin_transaction()
    check b.is_good
    discard c.execute("CREATE TABLE rx (v INT)")
    let rb = c.rollback()
    check rb.is_good

suite "monetdb dump":
  var c: Connection

  setup:
    c = connect(":memory:")
    discard c.open()

  teardown:
    discard c.close()

  test "dump database":
    discard c.execute("CREATE TABLE d (x INT)")
    let r = c.dump_database("/tmp/monetdb_test_dump.sql")
    check r.is_good
