#include <mruby.h>
#include <mruby/string.h>
#include <mruby/error.h>
#include <time.h>
#include <errno.h>

static mrb_value delayer_extend_ticks(mrb_state *mrb, mrb_value self) {
  struct timespec ts = {};
  if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) {
#ifdef MRB_WITHOUT_FLOAT
    return mrb_fixnum_value(ts.tv_sec);
#else
    return mrb_float_value(mrb, (mrb_float) ts.tv_sec + (mrb_float) ts.tv_nsec/1.0e9);
#endif
  } else {
    mrb_sys_fail(mrb, mrb_string_cstr(mrb, mrb_format(mrb, "clock_gettime failed (%d)", errno)));
  }
}

void mrb_mruby_delayer_gem_init(mrb_state *mrb) {
  struct RClass *mod_delayer = mrb_define_module(mrb, "Delayer");

  struct RClass *mod_delayer_extend = mrb_define_module_under(mrb, mod_delayer, "Extend");
  mrb_define_module_function(mrb, mod_delayer_extend, "ticks", delayer_extend_ticks, MRB_ARGS_NONE());
}

void mrb_mruby_delayer_gem_final(mrb_state *mrb) {
}
