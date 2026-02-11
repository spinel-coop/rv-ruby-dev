# Patches

Patches applied during Ruby builds where upstream hasn't yet incorporated a fix.

## `musl-thread-stack-fix.patch`

**Affects:** All Ruby versions on musl/Alpine Linux (3.2.x, 3.3.x, 3.4.x)
**Applied by:** `bin/build-alpine` (skipped automatically if the patch doesn't apply cleanly)

### What it fixes

musl's `pthread_getattr_np()` returns ~80 KB for the main thread's stack size,
compared to glibc's 2–10 MB. Ruby's default stack-size detection trusts this
value, which causes `SystemStackError` on even moderate recursion depths.

The patch replaces `pthread_getattr_np()` with a portable implementation that
parses `/proc/self/maps` to determine the actual stack bounds on non-glibc Linux.

### Provenance

This patch has a long history — first reported in 2018, never merged upstream:

- **Original report (2018):** https://bugs.ruby-lang.org/issues/14387 —
  filed against Ruby 2.5 on Alpine. Natanael Copa (Alpine Linux maintainer)
  wrote the patch, with stack-parsing code from Szabolcs Nagy. Closed in 2023
  when Ruby 2.5 reached EOL, but the patch was never merged into mainline Ruby.
- **Resurfaced (2023):** https://bugs.ruby-lang.org/issues/19716 —
  same issue in Ruby 3.1.4+. Status changed to "Feedback" because no Ruby core
  maintainer volunteers for musl/Alpine support.
- **Docker tracking issue:** https://github.com/docker-library/ruby/issues/196
- **Docker official ruby:alpine:** applies the same patch in the
  [Alpine Dockerfile](https://github.com/docker-library/ruby/blob/master/3.4/alpine3.23/Dockerfile#L88)
- **Alpine Linux aports:** also carries this patch as
  [`fix-get_main_stack.patch`](https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/ruby/fix-get_main_stack.patch)
  in Alpine's `ruby` package

### When can we remove it?

When Ruby upstream merges the fix into their release branches. Track the status
at https://bugs.ruby-lang.org/issues/19716. The `bin/build-alpine` script
already handles this gracefully — if the patch doesn't apply (because it's been
upstreamed), it skips it with a log message.
