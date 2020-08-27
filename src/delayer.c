#include <mruby.h>
#include <time.h>
#include <errno.h>

static mrb_value process_clock_gettime(mrb_state *mrb, mrb_value self) {
  mrb_value clock_id = mrb_get_arg1(mrb);
  if (!mrb_fixnum_p(clock_id)) {
    return mrb_nil_value();
  }

  struct timespec ts = {};
  if (clock_gettime(mrb_fixnum(clock_id), &ts) == 0) {
#ifdef MRB_WITHOUT_FLOAT
    return mrb_fixnum_value(ts.tv_sec);
#else
    return mrb_float_value(mrb, (mrb_float) ts.tv_sec + (mrb_float) ts.tv_nsec/1.0e9);
#endif
  } else {
    mrb_raisef(mrb, E_RUNTIME_ERROR, "clock_gettime() error %d", errno);
  }
}

void mrb_mruby_delayer_gem_init(mrb_state *mrb) {
  struct RClass *mod_delayer = mrb_define_module(mrb, "Delayer");

  struct RClass *mod_process = mrb_define_module_under(mrb, mod_delayer, "Process");
  mrb_define_module_function(mrb, mod_process, "clock_gettime", process_clock_gettime, MRB_ARGS_ARG(1, 1));
  mrb_define_const(mrb, mod_process, "CLOCK_MONOTONIC", mrb_fixnum_value(CLOCK_MONOTONIC));
}

void mrb_mruby_delayer_gem_final(mrb_state *mrb) {
}
