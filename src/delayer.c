#include <mruby.h>
#include <time.h>

static mrb_value process_clock_gettime(mrb_state *mrb, mrb_value self) {
  struct timespec ts = {};
  if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) {
    return mrb_fixnum_value(ts.tv_sec);
  } else {
    mrb_raise(mrb, E_RUNTIME_ERROR, "clock_gettime() error");
    return mrb_nil_value();
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
