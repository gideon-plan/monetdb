## MonetDB/e types and error mapping.

{.experimental: "strict_funcs".}

import std/times
import basis/code/choice
import monetdb/ffi

type
  FieldKind* {.pure.} = enum
    Bool
    Int8
    Int16
    Int32
    Int64
    Float
    Double
    String
    Blob
    Date
    Time
    Timestamp
    Null
    Unknown

  Field* = object
    case kind*: FieldKind
    of FieldKind.Bool: bval*: bool
    of FieldKind.Int8: i8*: int8
    of FieldKind.Int16: i16*: int16
    of FieldKind.Int32: i32*: int32
    of FieldKind.Int64: i64*: int64
    of FieldKind.Float: f32*: float32
    of FieldKind.Double: f64*: float64
    of FieldKind.String: str*: string
    of FieldKind.Blob: blob*: seq[byte]
    of FieldKind.Date: date*: DateTime
    of FieldKind.Time: time*: DateTime
    of FieldKind.Timestamp: ts*: DateTime
    of FieldKind.Null, FieldKind.Unknown: discard

  Row* = seq[Field]

  Connection* = ref object
    db*: ffi.Database
    path*: string
    memory_limit*: int
    query_timeout*: int
    session_timeout*: int
    threads*: int

let NullField* = Field(kind: FieldKind.Null)

func check_error*(msg: cstring): Choice[void] =
  ## Maps a MonetDB error cstring to Choice.
  if msg.isNil:
    return good()
  bad[void]("monetdb", $msg)

func map_type*(t: ffi.Types): FieldKind =
  case t
  of ffi.monetdbe_bool: FieldKind.Bool
  of ffi.monetdbe_int8_t: FieldKind.Int8
  of ffi.monetdbe_int16_t: FieldKind.Int16
  of ffi.monetdbe_int32_t: FieldKind.Int32
  of ffi.monetdbe_int64_t, ffi.monetdbe_int128_t: FieldKind.Int64
  of ffi.monetdbe_size_t: FieldKind.Int64
  of ffi.monetdbe_float: FieldKind.Float
  of ffi.monetdbe_double: FieldKind.Double
  of ffi.monetdbe_str: FieldKind.String
  of ffi.monetdbe_blob: FieldKind.Blob
  of ffi.monetdbe_date: FieldKind.Date
  of ffi.monetdbe_time: FieldKind.Time
  of ffi.monetdbe_timestamp: FieldKind.Timestamp
  of ffi.monetdbe_type_unknown: FieldKind.Unknown
