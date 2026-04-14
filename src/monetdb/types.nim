## MonetDB/e types and error mapping.

{.experimental: "strict_funcs".}

import std/times
import basis/code/choice
import monetdb/ffi

type
  FieldKind* = enum
    fkBool
    fkInt8
    fkInt16
    fkInt32
    fkInt64
    fkFloat
    fkDouble
    fkString
    fkBlob
    fkDate
    fkTime
    fkTimestamp
    fkNull
    fkUnknown

  Field* = object
    case kind*: FieldKind
    of fkBool: bval*: bool
    of fkInt8: i8*: int8
    of fkInt16: i16*: int16
    of fkInt32: i32*: int32
    of fkInt64: i64*: int64
    of fkFloat: f32*: float32
    of fkDouble: f64*: float64
    of fkString: str*: string
    of fkBlob: blob*: seq[byte]
    of fkDate: date*: DateTime
    of fkTime: time*: DateTime
    of fkTimestamp: ts*: DateTime
    of fkNull, fkUnknown: discard

  Row* = seq[Field]

  Connection* = ref object
    db*: ffi.Database
    path*: string
    memory_limit*: int
    query_timeout*: int
    session_timeout*: int
    threads*: int

let NullField* = Field(kind: fkNull)

func check_error*(msg: cstring): Choice[void] =
  ## Maps a MonetDB error cstring to Choice.
  if msg.isNil:
    return Good[void]()
  Bad[void]($msg)

func map_type*(t: ffi.Types): FieldKind =
  case t
  of ffi.monetdbe_bool: fkBool
  of ffi.monetdbe_int8_t: fkInt8
  of ffi.monetdbe_int16_t: fkInt16
  of ffi.monetdbe_int32_t: fkInt32
  of ffi.monetdbe_int64_t, ffi.monetdbe_int128_t: fkInt64
  of ffi.monetdbe_size_t: fkInt64
  of ffi.monetdbe_float: fkFloat
  of ffi.monetdbe_double: fkDouble
  of ffi.monetdbe_str: fkString
  of ffi.monetdbe_blob: fkBlob
  of ffi.monetdbe_date: fkDate
  of ffi.monetdbe_time: fkTime
  of ffi.monetdbe_timestamp: fkTimestamp
  of ffi.monetdbe_type_unknown: fkUnknown
