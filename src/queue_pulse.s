.section __TEXT,__text,regular,pure_instructions
.p2align 2
.globl _main

_main:
  stp x29, x30, [sp, -16]!
  mov x29, sp
  sub sp, sp, #64

  mov x19, x0
  mov x20, x1

  cmp x19, #2
  b.ge L_has_cmd
  bl _print_usage
  mov w0, #1
  b L_done

L_has_cmd:
  ldr x0, [x20, #8]
  adrp x1, _cmd_add@PAGE
  add x1, x1, _cmd_add@PAGEOFF
  bl _strcmp
  cbz w0, L_add

  ldr x0, [x20, #8]
  adrp x1, _cmd_summary@PAGE
  add x1, x1, _cmd_summary@PAGEOFF
  bl _strcmp
  cbz w0, L_summary

  ldr x0, [x20, #8]
  adrp x1, _cmd_recent@PAGE
  add x1, x1, _cmd_recent@PAGEOFF
  bl _strcmp
  cbz w0, L_recent

  bl _print_usage
  mov w0, #1
  b L_done

L_add:
  cmp x19, #5
  b.ge L_add_ok
  bl _print_add_usage
  mov w0, #1
  b L_done

L_add_ok:
  bl _connect_db
  cbz x0, L_fail
  mov x21, x0

  ldr x22, [x20, #16]
  ldr x23, [x20, #24]
  ldr x24, [x20, #32]

  str x22, [sp, #0]
  str x23, [sp, #8]
  str x24, [sp, #16]

  mov x0, x21
  adrp x1, _sql_add@PAGE
  add x1, x1, _sql_add@PAGEOFF
  mov w2, #3
  mov x3, #0
  add x4, sp, #0
  mov x5, #0
  mov x6, #0
  mov w7, #0
  bl _PQexecParams
  mov x25, x0
  cbz x25, L_add_err

  mov x0, x25
  bl _PQresultStatus
  cmp w0, #1
  b.eq L_add_success

L_add_err:
  adrp x0, _msg_add_fail@PAGE
  add x0, x0, _msg_add_fail@PAGEOFF
  bl _printf
  b L_add_cleanup

L_add_success:
  adrp x0, _msg_add_ok@PAGE
  add x0, x0, _msg_add_ok@PAGEOFF
  bl _printf

L_add_cleanup:
  cbz x25, L_add_finish
  mov x0, x25
  bl _PQclear
L_add_finish:
  mov x0, x21
  bl _PQfinish
  mov w0, #0
  b L_done

L_summary:
  bl _connect_db
  cbz x0, L_fail
  mov x21, x0

  mov x0, x21
  adrp x1, _sql_summary@PAGE
  add x1, x1, _sql_summary@PAGEOFF
  bl _PQexec
  mov x25, x0
  cbz x25, L_summary_err

  mov x0, x25
  bl _PQresultStatus
  cmp w0, #2
  b.ne L_summary_err

  mov x0, x25
  bl _PQntuples
  mov w26, w0
  cbz w26, L_summary_empty

  mov w27, #0
L_summary_loop:
  cmp w27, w26
  b.ge L_summary_done

  mov x0, x25
  mov w1, w27
  mov w2, #0
  bl _PQgetvalue
  mov x22, x0

  mov x0, x25
  mov w1, w27
  mov w2, #0
  bl _PQgetlength
  mov w24, w0

  mov x0, x25
  mov w1, w27
  mov w2, #1
  bl _PQgetvalue
  mov x23, x0

  mov x0, x25
  mov w1, w27
  mov w2, #1
  bl _PQgetlength
  mov w28, w0

  mov w0, #1
  mov x1, x22
  mov w2, w24
  bl _write

  mov w0, #1
  adrp x1, _summary_sep@PAGE
  add x1, x1, _summary_sep@PAGEOFF
  mov w2, #2
  bl _write

  mov w0, #1
  mov x1, x23
  mov w2, w28
  bl _write

  mov w0, #1
  adrp x1, _summary_nl@PAGE
  add x1, x1, _summary_nl@PAGEOFF
  mov w2, #1
  bl _write

  add w27, w27, #1
  b L_summary_loop

L_summary_empty:
  adrp x0, _msg_summary_empty@PAGE
  add x0, x0, _msg_summary_empty@PAGEOFF
  bl _printf
  b L_summary_done

L_summary_err:
  adrp x0, _msg_summary_fail@PAGE
  add x0, x0, _msg_summary_fail@PAGEOFF
  bl _printf

L_summary_done:
  cbz x25, L_summary_finish
  mov x0, x25
  bl _PQclear
L_summary_finish:
  mov x0, x21
  bl _PQfinish
  mov w0, #0
  b L_done

L_recent:
  bl _connect_db
  cbz x0, L_fail
  mov x21, x0

  cmp x19, #3
  b.ge L_recent_limit_arg
  adrp x22, _recent_default@PAGE
  add x22, x22, _recent_default@PAGEOFF
  b L_recent_param_ready

L_recent_limit_arg:
  ldr x22, [x20, #16]

L_recent_param_ready:
  str x22, [sp, #0]
  mov x0, x21
  adrp x1, _sql_recent@PAGE
  add x1, x1, _sql_recent@PAGEOFF
  mov w2, #1
  mov x3, #0
  add x4, sp, #0
  mov x5, #0
  mov x6, #0
  mov w7, #0
  bl _PQexecParams
  mov x25, x0
  cbz x25, L_recent_err

  mov x0, x25
  bl _PQresultStatus
  cmp w0, #2
  b.ne L_recent_err

  mov x0, x25
  bl _PQntuples
  mov w26, w0
  cbz w26, L_recent_empty

  mov w27, #0
L_recent_loop:
  cmp w27, w26
  b.ge L_recent_done

  mov x0, x25
  mov w1, w27
  mov w2, #0
  bl _PQgetvalue
  mov x9, x0

  mov x0, x25
  mov w1, w27
  mov w2, #0
  bl _PQgetlength
  mov w10, w0

  mov w0, #1
  mov x1, x9
  mov w2, w10
  bl _write

  mov w0, #1
  adrp x1, _recent_sep@PAGE
  add x1, x1, _recent_sep@PAGEOFF
  mov w2, #3
  bl _write

  mov x0, x25
  mov w1, w27
  mov w2, #1
  bl _PQgetvalue
  mov x9, x0

  mov x0, x25
  mov w1, w27
  mov w2, #1
  bl _PQgetlength
  mov w10, w0

  mov w0, #1
  mov x1, x9
  mov w2, w10
  bl _write

  mov w0, #1
  adrp x1, _recent_sep@PAGE
  add x1, x1, _recent_sep@PAGEOFF
  mov w2, #3
  bl _write

  mov x0, x25
  mov w1, w27
  mov w2, #2
  bl _PQgetvalue
  mov x9, x0

  mov x0, x25
  mov w1, w27
  mov w2, #2
  bl _PQgetlength
  mov w10, w0

  mov w0, #1
  mov x1, x9
  mov w2, w10
  bl _write

  mov w0, #1
  adrp x1, _recent_sep@PAGE
  add x1, x1, _recent_sep@PAGEOFF
  mov w2, #3
  bl _write

  mov x0, x25
  mov w1, w27
  mov w2, #3
  bl _PQgetvalue
  mov x9, x0

  mov x0, x25
  mov w1, w27
  mov w2, #3
  bl _PQgetlength
  mov w10, w0

  mov w0, #1
  mov x1, x9
  mov w2, w10
  bl _write

  mov w0, #1
  adrp x1, _summary_nl@PAGE
  add x1, x1, _summary_nl@PAGEOFF
  mov w2, #1
  bl _write

  add w27, w27, #1
  b L_recent_loop

L_recent_empty:
  adrp x0, _msg_recent_empty@PAGE
  add x0, x0, _msg_recent_empty@PAGEOFF
  bl _printf
  b L_recent_done

L_recent_err:
  adrp x0, _msg_recent_fail@PAGE
  add x0, x0, _msg_recent_fail@PAGEOFF
  bl _printf

L_recent_done:
  cbz x25, L_recent_finish
  mov x0, x25
  bl _PQclear
L_recent_finish:
  mov x0, x21
  bl _PQfinish
  mov w0, #0
  b L_done

L_fail:
  mov w0, #1

L_done:
  add sp, sp, #64
  ldp x29, x30, [sp], #16
  ret

_print_usage:
  stp x29, x30, [sp, -16]!
  mov x29, sp
  adrp x0, _msg_usage@PAGE
  add x0, x0, _msg_usage@PAGEOFF
  bl _printf
  ldp x29, x30, [sp], #16
  ret

_print_add_usage:
  stp x29, x30, [sp, -16]!
  mov x29, sp
  adrp x0, _msg_add_usage@PAGE
  add x0, x0, _msg_add_usage@PAGEOFF
  bl _printf
  ldp x29, x30, [sp], #16
  ret

_connect_db:
  stp x29, x30, [sp, -16]!
  mov x29, sp
  stp x19, x20, [sp, -16]!
  sub sp, sp, #32

  adrp x0, _env_db@PAGE
  add x0, x0, _env_db@PAGEOFF
  bl _getenv
  cbz x0, L_env_missing

  mov x19, x0
  mov x0, x19
  bl _PQconnectdb
  mov x20, x0
  cbz x20, L_conn_fail

  mov x0, x20
  bl _PQstatus
  cbz w0, L_conn_ok

L_conn_fail:
  mov x0, x20
  bl _PQerrorMessage
  mov x1, x0
  adrp x0, _fmt_conn_fail@PAGE
  add x0, x0, _fmt_conn_fail@PAGEOFF
  bl _printf

  cbz x20, L_conn_fail_done
  mov x0, x20
  bl _PQfinish
L_conn_fail_done:
  mov x0, #0
  b L_connect_done

L_env_missing:
  adrp x0, _msg_env_missing@PAGE
  add x0, x0, _msg_env_missing@PAGEOFF
  bl _printf
  mov x0, #0
  b L_connect_done

L_conn_ok:
  mov x0, x20

L_connect_done:
  add sp, sp, #32
  ldp x19, x20, [sp], #16
  ldp x29, x30, [sp], #16
  ret

.section __TEXT,__cstring,cstring_literals
_cmd_add: .asciz "add"
_cmd_summary: .asciz "summary"
_cmd_recent: .asciz "recent"
_env_db: .asciz "DATABASE_URL"

_msg_usage: .asciz "Usage:\n  gs-queue-pulse add <source> <priority> <note>\n  gs-queue-pulse summary\n  gs-queue-pulse recent [limit]\n"
_msg_add_usage: .asciz "Usage: gs-queue-pulse add <source> <priority> <note>\n"
_msg_add_ok: .asciz "Logged signal.\n"
_msg_add_fail: .asciz "Failed to log signal.\n"
_msg_summary_fail: .asciz "Failed to load summary.\n"
_msg_summary_empty: .asciz "No signals yet.\n"
_msg_recent_fail: .asciz "Failed to load recent signals.\n"
_msg_recent_empty: .asciz "No recent signals.\n"
_msg_env_missing: .asciz "DATABASE_URL is not set.\n"
_fmt_conn_fail: .asciz "DB connection failed: %s\n"
_summary_sep: .asciz ": "
_summary_nl: .asciz "\n"
_recent_sep: .asciz " | "
_recent_default: .asciz "5"

_sql_add: .asciz "INSERT INTO groupscholar_queue_pulse.signals (source, priority, note) VALUES ($1, $2, $3);"
_sql_summary: .asciz "SELECT priority, COUNT(*)::text FROM groupscholar_queue_pulse.signals GROUP BY priority ORDER BY COUNT(*) DESC;"
_sql_recent: .asciz "SELECT source, priority, note, to_char(reported_at, 'YYYY-MM-DD HH24:MI') FROM groupscholar_queue_pulse.signals ORDER BY reported_at DESC LIMIT $1;"
