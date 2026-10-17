
%
% Time of Generation:
% Sun Oct 11 10:52:56 AM +04 2026
%

%%
%%%%%%
%
% HX-2015-07:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [basics_cats.hrl]
%%%%%%
%%

%% ****** ****** %%

-define(ATSCKiseqz(X), X =:= 0).
-define(ATSCKisneqz(X), X =/= 0).

%% ****** ****** %%

-define(ATSCKpat_int(X, I), X =:= I).
-define(ATSCKpat_bool(X, B), X =:= B).

%% ****** ****** %%

-define(ATSCKpat_string(X, S), X =:= S).

%% ****** ****** %%

-define(ATSCKpat_con0(X, TAG), X =:= TAG).
-define(ATSCKpat_con1(X, TAG), (is_tuple(X) andalso (element(1, X) =:= TAG))).

%% ****** ****** %%

-define(ATSCKptrisnull(X), X =:= atscc2erl_null).
-define(ATSCKptriscons(X), X =/= atscc2erl_null).

%% ****** ****** %%

-define(ATSSELcon(P, I), element(I+1, P)).
-define(ATSSELboxrec(P, I), element(I+1, P)).
-define(ATSSELfltrec(P, I), element(I+1, P)). %% HX-2026-10: flat records

%% ****** ****** %%

-define(ATSfunclo_fun(F), (F)).
-define(ATSfunclo_clo(F), (element(1, F))).

%% ****** ****** %%
%%
-define(ATSINSmove_void(), atscc2erl_void).
%%
%% ****** ****** %%
%%
%%fun%%
atscc2erl_caseof_deadcode
  (_FILE, _LINE) -> exit('atscc2erl_caseof_deadcode').
%%
%% ****** ****** %%

-define(ATSINScaseof_fail(ERRMSG), exit({'atscc2erl_caseof_fail', ERRMSG})).

%% ****** ****** %%

%%fun%%
ats2erlpre_string2atom(S) -> list_to_atom(S).
%%fun%%
ats2erlpre_atom2string(S) -> atom_to_list(S).

%% ****** ****** %%
%%
%% HX-2026-10:
%% linear lazy values: a thunk is called with true
%% to evaluate it and with false to free it
-define(ATSPMVllazyval_eval(LV), ?ATSfunclo_clo(LV)(LV, true)).
%%fun%%
atspre_lazy_vt_free(LV) -> ?ATSfunclo_clo(LV)(LV, false).
%%
%% HX-2026-10:
%% for building options (Option_vt) in the runtime
%% (they used to be implemented in [option.dats])
%%fun%%
ats2erlpre_option_some(X) -> {X}.
%%fun%%
ats2erlpre_option_none() -> atscc2erl_null.
%%
%% ****** ****** %%

%%
%% HX-2015-10-25:
%% Commenting out
%% implementation in basics.dats
%%
ats2erlpre_cloref0_app
  (F) -> ?ATSfunclo_clo(F)(F).
ats2erlpre_cloref1_app
  (F, X1) -> ?ATSfunclo_clo(F)(F, X1).
ats2erlpre_cloref2_app
  (F, X1, X2) -> ?ATSfunclo_clo(F)(F, X1, X2).
ats2erlpre_cloref3_app
  (F, X1, X2, X3) -> ?ATSfunclo_clo(F)(F, X1, X2, X3).
%%

%% ****** ****** %%
%%
ats2erlpre_cloref2fun0(F) ->
  fun() -> ats2erlpre_cloref0_app(F) end.
ats2erlpre_cloref2fun1(F) ->
  fun(X1) -> ats2erlpre_cloref1_app(F, X1) end.
ats2erlpre_cloref2fun2(F) ->
  fun(X1, X2) -> ats2erlpre_cloref2_app(F, X1, X2) end.
ats2erlpre_cloref2fun3(F) ->
  fun(X1, X2, X3) -> ats2erlpre_cloref3_app(F, X1, X2, X3) end.
%%
%% ****** ****** %%

%% end of [basics_cats.hrl] %%
%%
%%%%%%
%
% HX-2015-07:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [integer_cats.hrl]
%%%%%%
%%

%% ****** ****** %%
%%
%% HX: for signed integers
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_abs_int0(X) -> abs(X).
%%fun%%
ats2erlpre_abs_int1(X) -> abs(X).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_neg_int0(X) -> ( -X ).
%%fun%%
ats2erlpre_neg_int1(X) -> ( -X ).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_succ_int0(X) -> (X + 1).
%%fun%%
ats2erlpre_pred_int0(X) -> (X - 1).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_succ_int1(X) -> (X + 1).
%%fun%%
ats2erlpre_pred_int1(X) -> (X - 1).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_half_int0(X) -> (X div 2).
%%fun%%
ats2erlpre_half_int1(X) -> (X div 2).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_add_int0_int0(X, Y) -> (X + Y).
%%fun%%
ats2erlpre_sub_int0_int0(X, Y) -> (X - Y).
%%fun%%
ats2erlpre_mul_int0_int0(X, Y) -> (X * Y).
%%fun%%
ats2erlpre_div_int0_int0(X, Y) -> (X div Y).
%%fun%%
ats2erlpre_mod_int0_int0(X, Y) -> (X rem Y).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_add_int1_int1(X, Y) -> (X + Y).
%%fun%%
ats2erlpre_sub_int1_int1(X, Y) -> (X - Y).
%%fun%%
ats2erlpre_mul_int1_int1(X, Y) -> (X * Y).
%%fun%%
ats2erlpre_div_int1_int1(X, Y) -> (X div Y).
%%fun%%
ats2erlpre_mod_int1_int1(X, Y) -> (X rem Y).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_lt_int0_int0(X, Y) -> (X < Y).
%%fun%%
ats2erlpre_lte_int0_int0(X, Y) -> (X =< Y).
%%fun%%
ats2erlpre_gt_int0_int0(X, Y) -> (X > Y).
%%fun%%
ats2erlpre_gte_int0_int0(X, Y) -> (X >= Y).
%%fun%%
ats2erlpre_eq_int0_int0(X, Y) -> (X =:= Y).
%%fun%%
ats2erlpre_neq_int0_int0(X, Y) -> (X =/= Y).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_compare_int0_int0
  (X, Y) ->
%{
  if X > Y -> 1; X < Y -> -1; true -> 0 end.
%}
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_lt_int1_int1(X, Y) -> (X < Y).
%%fun%%
ats2erlpre_lte_int1_int1(X, Y) -> (X =< Y).
%%fun%%
ats2erlpre_gt_int1_int1(X, Y) -> (X > Y).
%%fun%%
ats2erlpre_gte_int1_int1(X, Y) -> (X >= Y).
%%fun%%
ats2erlpre_eq_int1_int1(X, Y) -> (X =:= Y).
%%fun%%
ats2erlpre_neq_int1_int1(X, Y) -> (X =/= Y).
%%
%% ****** ****** %%

%% end of [integer_cats.hrl] %%
%%
%%%%%%
%
% HX-2015-07:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [bool_cats.hrl]
%%%%%%
%%

%% ****** ****** %%
%%
%%fun%%
ats2erlpre_neg_bool0(X) -> not(X).
%%fun%%
ats2erlpre_neg_bool1(X) -> not(X).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_eq_bool0_bool0(X, Y) -> (X =:= Y).
%%fun%%
ats2erlpre_neq_bool0_bool0(X, Y) -> (X =/= Y).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_eq_bool1_bool1(X, Y) -> (X =:= Y).
%%fun%%
ats2erlpre_neq_bool1_bool1(X, Y) -> (X =/= Y).
%%
%% ****** ****** %%

%% end of [bool_cats.js] %%
%%
%%%%%%
%
% HX-2015-07:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [float_cats.hrl]
%%%%%%
%%

%% ****** ****** %%
%%
%%fun%%
ats2erlpre_neg_double(X) -> ( -X ).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_succ_double(X) -> (X + 1).
%%fun%%
ats2erlpre_pred_double(X) -> (X - 1).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_add_double_double(X, Y) -> (X + Y).
%%fun%%
ats2erlpre_sub_double_double(X, Y) -> (X - Y).
%%fun%%
ats2erlpre_mul_double_double(X, Y) -> (X * Y).
%%fun%%
ats2erlpre_div_double_double(X, Y) -> (X / Y).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_lt_double_double(X, Y) -> (X < Y).
%%fun%%
ats2erlpre_lte_double_double(X, Y) -> (X =< Y).
%%fun%%
ats2erlpre_gt_double_double(X, Y) -> (X > Y).
%%fun%%
ats2erlpre_gte_double_double(X, Y) -> (X >= Y).
%%fun%%
ats2erlpre_eq_double_double(X, Y) -> (X =:= Y).
%%fun%%
ats2erlpre_neq_double_double(X, Y) -> (X =/= Y).
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_compare_double_double
  (X, Y) ->
%{
  if X > Y -> 1; X < Y -> -1; true -> 0 end.
%}
%%
%% ****** ****** %%

%% end of [float_cats.hrl] %%
%%
%%%%%%
%
% HX-2015-07:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [print_cats.hrl]
%%%%%%
%%

%% ****** ****** %%
%%
%%fun%%
ats2erlpre_print_int(X) -> io:format("~B", [X]).
%%
%%fun%%
ats2erlpre_print_bool(X) ->
  ats2erlpre_print_string(if X->"true"; true->"false" end).
%%
%%fun%%
ats2erlpre_print_double(X) -> io:format("~f", [X]).
%%fun%%
ats2erlpre_print_string(X) -> io:format("~s", [X]).
%%
%%fun%%
ats2erlpre_print_ERLval(X) -> io:format("~p", [X]).
%%
%%fun%%
ats2erlpre_print_newline() -> io:format("~n", []).
%%
%% ****** ****** %%

%% end of [print_cats.hrl] %%
%%
%%%%%%
%
% HX-2015-07:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [reference_cats.hrl]
%%%%%%
%%

%% ****** ****** %%
%%
%%fun%%
ats2erlpre_ref(X) ->
  spawn(
    ?MODULE, ats2erlpre_ref_server_proc, [X]
  ). %% spawn
%%fun%%
ats2erlpre_ref_make_elt(X) ->
  spawn(
    ?MODULE, ats2erlpre_ref_server_proc, [X]
  ). %% spawn
%%
ats2erlpre_ref_server_proc(X) ->
  receive
    {Client, get_elt} ->
      Client ! {self(), X}, ats2erlpre_ref_server_proc(X);
    {Client, set_elt, Y} ->
      Client ! {self(), atscc2erl_void}, ats2erlpre_ref_server_proc(Y);
    {Client, exch_elt, Y} ->
      Client ! {self(), X}, ats2erlpre_ref_server_proc(Y);
    {Client, takeout} ->
      Client ! {self(), X}, ats2erlpre_ref_server_proc2()
  end.
ats2erlpre_ref_server_proc2() ->
  receive
    {Client, addback, X} -> 
      Client ! {self(), atscc2erl_void}, ats2erlpre_ref_server_proc(X)
  end.
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_ref_get_elt(Server) ->
  Server ! {self(), get_elt}, receive {Server, Res} -> Res end.
%%fun%%
ats2erlpre_ref_set_elt(Server, Y) ->
  Server ! {self(), set_elt, Y}, receive {Server, Res} -> Res end.
%%fun%%
ats2erlpre_ref_exch_elt(Server, Y) ->
  Server ! {self(), exch_elt, Y}, receive {Server, Res} -> Res end.
%%
%%fun%%
ats2erlpre_ref_takeout(Server) ->
  Server ! {self(), takeout}, receive {Server, Res} -> Res end.
ats2erlpre_ref_addback(Server, Y) ->
  Server ! {self(), addback, Y}, receive {Server, Res} -> Res end.
%%
%% ****** ****** %%
%%
%% HX: linear references
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_ref_vt(X) ->
  spawn(
    ?MODULE, ats2erlpre_ref_vt_server_proc, [X]
  ). %% spawn
%%fun%%
ats2erlpre_ref_vt_make_elt(X) ->
  spawn(
    ?MODULE, ats2erlpre_ref_vt_server_proc, [X]
  ). %% spawn
%%
ats2erlpre_ref_vt_server_proc(X) ->
  receive
    {Client, get_elt} ->
      Client ! {self(), X}, ats2erlpre_ref_vt_server_proc(X);
    {Client, set_elt, Y} ->
      Client ! {self(), atscc2erl_void}, ats2erlpre_ref_vt_server_proc(Y);
    {Client, exch_elt, Y} ->
      Client ! {self(), Y}, ats2erlpre_ref_vt_server_proc(Y);
    {Client, takeout} ->
      Client ! {self(), X}, ats2erlpre_ref_vt_server_proc2();
    {Client, getfree_elt} -> Client ! {self(), X} %% Server exits here
  end.
ats2erlpre_ref_vt_server_proc2() ->
  receive
    {Client, addback, X} -> 
      Client ! {self(), atscc2erl_void}, ats2erlpre_ref_vt_server_proc(X)
  end.
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlpre_ref_vt_get_elt(Server) ->
  Server ! {self(), get_elt}, receive {Server, Res} -> Res end.
%%fun%%
ats2erlpre_ref_vt_set_elt(Server, Y) ->
  Server ! {self(), set_elt, Y}, receive {Server, Res} -> Res end.
%%fun%%
ats2erlpre_ref_vt_exch_elt(Server, Y) ->
  Server ! {self(), exch_elt, Y}, receive {Server, Res} -> Res end.
%%
ats2erlpre_ref_vt_getfree_elt(Server) ->
  Server ! {self(), getfree_elt}, receive {Server, Res} -> Res end.
%%
%%fun%%
ats2erlpre_ref_vt_takeout(Server) ->
  Server ! {self(), takeout}, receive {Server, Res} -> Res end.
ats2erlpre_ref_vt_addback(Server, Y) ->
  Server ! {self(), addback, Y}, receive {Server, Res} -> Res end.
%%
%% ****** ****** %%

%% end of [reference_cats.hrl] %%
%%
%%%%%%
%
% HX-2015-09:
% for Erlang code
% translated from ATS
%
%%%%%%
%%

%%
%%%%%%
% beg of [file_cats.hrl]
%%%%%%
%%

%% ****** ****** %%
%%fun%%
ats2erlibc_filename_all2string
  (X) ->
  case X of
    _ when is_list(X) -> X;
    _ when is_binary(X) -> binary:bin_to_list(X)
  end.
%%
%% ****** ****** %%

%%fun%%
ats2erlibc_file_print_filename(X) -> io:format("~p", [X]).
%%fun%%
ats2erlibc_file_print_filename_all(X) -> io:format("~p", [X]).

%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2get_cwd_0_opt
  () ->
  case file:get_cwd() of
    {ok, Filename} ->
      ats2erlpre_option_some(Filename)
    ; %% Some(Filename)
    {error, _Reason_} ->
      ats2erlpre_option_none() %% None((*void*))
  end.
%%fun%%
ats2erlibc_file_ats2get_cwd_1_opt
  (Drive) ->
  case file:get_cwd(Drive) of
    {ok, Filename} ->
      ats2erlpre_option_some(Filename)
    ; %% Some(Filename)
    {error, _Reason_} ->
      ats2erlpre_option_none() %% None((*void*))
  end.
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2del_dir_opt
  (Dir) ->
  case
  file:del_dir(Dir)
  of %% of-case
    ok -> true; {error, _Reason_} -> false
  end. %% end-case
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2list_dir_opt
  (Dir) ->
  case
  file:list_dir(Dir)
  of %% case
    {ok, Filenames} ->
      ats2erlpre_option_some(Filenames)
    ; %% Some(Filename)
    {error, _Reason_} ->
      ats2erlpre_option_none() %% None((*void*))
  end.
%%
%%fun%%
ats2erlibc_file_ats2list_dir_all_opt
  (Dir) ->
  case
  file:list_dir_all(Dir)
  of %% case
    {ok, Filenames} ->
      ats2erlpre_option_some(Filenames)
    ; %% Some(Filename)
    {error, _Reason_} ->
      ats2erlpre_option_none() %% None((*void*))
  end.
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2make_dir_opt
  (Dir) ->
  case
  file:make_dir(Dir)
  of %% of-case
    ok -> true; {error, _Reason_} -> false
  end. %% end-case
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2make_link_opt
  (Existing, New) ->
  case
  file:make_link(Existing, New)
  of %% of-case
    ok -> true; {error, _Reason_} -> false
  end. %% end-case
%%
%%fun%%
ats2erlibc_file_ats2make_symlink_opt
  (Existing, New) ->
  case
  file:make_symlink(Existing, New)
  of %% of-case
    ok -> true; {error, _Reason_} -> false
  end. %% end-case
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2read_file_opt
  (Filename) ->
  case
  file:read_file(Filename)
  of %% case
    {ok, Binary} ->
      ats2erlpre_option_some(Binary)
    ; %% Some(Filename)
    {error, _Reason_} ->
      ats2erlpre_option_none() %% None((*void*))
  end.
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2rename_opt
  (Src, Dst) ->
  case
  file:rename(Src, Dst)
  of %% of-case
    ok -> true; {error, _Reason_} -> false
  end. %% end-case
%%
%% ****** ****** %%
%%
%%fun%%
ats2erlibc_file_ats2set_cwd_opt
  (Dir) ->
  case
  file:set_cwd(Dir)
  of %% of-case
    ok -> true; {error, _Reason_} -> false
  end. %% end-case
%%
%% ****** ****** %%

%% end of [file_cats.hrl] %%
%%%%%%
%%
%% The Erlang code is generated by atscc2erl
%% The starting compilation time is: 2026-10-11: 10h:52m
%%
%%%%%%
%%%%%%
%%
%% end-of-compilation-unit
%%
%%%%%%
%%%%%%
%%
%% The Erlang code is generated by atscc2erl
%% The starting compilation time is: 2026-10-11: 10h:52m
%%
%%%%%%

%%fun%%
ats2erlpre_list_vt_length(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret2
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_length,
  f_ats2erlpre_list_loop_3(Arg0, 0).
%} // end-of-function


%%fun%%
f_ats2erlpre_list_loop_3(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret3
%% var Tmp5
%% var Tmp6
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_list_loop_3,
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Arg0)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      Arg1;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp5 = ?ATSSELcon(Arg0, 1),
      Tmp6 = ats2erlpre_add_int1_int1(Arg1, 1),
      f_ats2erlpre_list_loop_3(Tmp5, Tmp6);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_list_vt_snoc(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret7
%% var Tmp8
%% var Tmp9
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_snoc,
  Tmp9 = atscc2erl_null,
  Tmp8 = {Arg1, Tmp9},
  ats2erlpre_list_vt_append(Arg0, Tmp8).
%} // end-of-function


%%fun%%
ats2erlpre_list_vt_extend(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret10
%% var Tmp11
%% var Tmp12
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_extend,
  Tmp12 = atscc2erl_null,
  Tmp11 = {Arg1, Tmp12},
  ats2erlpre_list_vt_append(Arg0, Tmp11).
%} // end-of-function


%%fun%%
ats2erlpre_list_vt_append(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret13
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_append,
  f_ats2erlpre_list_aux_7(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_list_aux_7(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret14
%% var Tmp15
%% var Tmp16
%% var Tmp17
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_list_aux_7,
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Arg0)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      Arg1;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp15 = ?ATSSELcon(Arg0, 0),
      Tmp16 = ?ATSSELcon(Arg0, 1),
      %% ATSINSfreecon(Arg0);,
      Tmp17 = f_ats2erlpre_list_aux_7(Tmp16, Arg1),
      {Tmp15, Tmp17};
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_list_vt_reverse(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret18
%% var Tmp19
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_reverse,
  Tmp19 = atscc2erl_null,
  ats2erlpre_list_vt_reverse_append(Arg0, Tmp19).
%} // end-of-function


%%fun%%
ats2erlpre_list_vt_reverse_append(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret20
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_reverse_append,
  f_ats2erlpre_list_loop_10(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_list_loop_10(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret21
%% var Tmp22
%% var Tmp23
%% var Tmp24
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_list_loop_10,
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Arg0)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      Arg1;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp22 = ?ATSSELcon(Arg0, 0),
      Tmp23 = ?ATSSELcon(Arg0, 1),
      %% ATSINSfreecon(Arg0);,
      Tmp24 = {Tmp22, Arg1},
      f_ats2erlpre_list_loop_10(Tmp23, Tmp24);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_list_vt_free(Arg0) ->
%{
%%
%% knd = 0
%% var Tmp27
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list_vt_free,
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Arg0)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      ?ATSINSmove_void();
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp27 = ?ATSSELcon(Arg0, 1),
      %% ATSINSfreecon(Arg0);,
      ats2erlpre_list_vt_free(Tmp27);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function

%%%%%%
%%
%% end-of-compilation-unit
%%
%%%%%%
%%%%%%
%%
%% The Erlang code is generated by atscc2erl
%% The starting compilation time is: 2026-10-11: 10h:52m
%%
%%%%%%

%%fun%%
f_ats2erlpre_stream_vt_patsfun_10__closurerize(XEnv0, XEnv1) -> 
%{
  {fun({_, Cenv1, Cenv2}, XArg0) -> f_ats2erlpre_stream_vt_patsfun_10(Cenv1, Cenv2, XArg0) end, XEnv0, XEnv1}.
%}


%%fun%%
f_ats2erlpre_stream_vt_patsfun_19__closurerize(XEnv0, XEnv1) -> 
%{
  {fun({_, Cenv1, Cenv2}, XArg0) -> f_ats2erlpre_stream_vt_patsfun_19(Cenv1, Cenv2, XArg0) end, XEnv0, XEnv1}.
%}


%%fun%%
f_ats2erlpre_stream_vt_patsfun_22__closurerize(XEnv0) -> 
%{
  {fun({_, Cenv1}, XArg0) -> f_ats2erlpre_stream_vt_patsfun_22(Cenv1, XArg0) end, XEnv0}.
%}


%%fun%%
f_ats2erlpre_stream_vt_patsfun_25__closurerize(XEnv0, XEnv1) -> 
%{
  {fun({_, Cenv1, Cenv2}, XArg0) -> f_ats2erlpre_stream_vt_patsfun_25(Cenv1, Cenv2, XArg0) end, XEnv0, XEnv1}.
%}


%%fun%%
f_ats2erlpre_stream_vt_patsfun_29__closurerize(XEnv0, XEnv1) -> 
%{
  {fun({_, Cenv1, Cenv2}, XArg0) -> f_ats2erlpre_stream_vt_patsfun_29(Cenv1, Cenv2, XArg0) end, XEnv0, XEnv1}.
%}


%%fun%%
f_ats2erlpre_stream_vt_patsfun_42__closurerize(XEnv0, XEnv1) -> 
%{
  {fun({_, Cenv1, Cenv2}, XArg0) -> f_ats2erlpre_stream_vt_patsfun_42(Cenv1, Cenv2, XArg0) end, XEnv0, XEnv1}.
%}


%%fun%%
ats2erlpre_stream_vt_free(Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_free,
  atspre_lazy_vt_free(Arg0).
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_takeLte(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret11
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_takeLte,
  f_ats2erlpre_stream_vt_auxmain_9(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_9(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret12
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_9,
  f_ats2erlpre_stream_vt_patsfun_10__closurerize(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_patsfun_10(Env0, Env1, Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret13
%% var Tmp14
%% var Tmp15
%% var Tmp16
%% var Tmp17
%% var Tmp18
%% var Tmp19
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_patsfun_10,
  if
    Arg0 ->
      Tmp14 = ats2erlpre_gt_int1_int1(Env1, 0),
      if
        Tmp14 ->
          Tmp15 = ?ATSPMVllazyval_eval(Env0),
          begin
          Casefunx1 =
          fun (Casefun, Tmplab) ->
            %switch(Tmplab) {
            case Tmplab of
              %% ATSbranchseq_beg
              1 ->
              if(?ATSCKptriscons(Tmp15)) -> Casefun(Casefun, 4); true ->
                Casefun(Casefun, 2)
              end;
              2 ->
              atscc2erl_null;
              %% ATSbranchseq_end
              %% ATSbranchseq_beg
              3 ->
              Casefun(Casefun, 4);
              4 ->
              Tmp16 = ?ATSSELcon(Tmp15, 0),
              Tmp17 = ?ATSSELcon(Tmp15, 1),
              %% ATSINSfreecon(Tmp15);,
              Tmp19 = ats2erlpre_sub_int1_int1(Env1, 1),
              Tmp18 = f_ats2erlpre_stream_vt_auxmain_9(Tmp17, Tmp19),
              {Tmp16, Tmp18};
              %% ATSbranchseq_end
              _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
            end %% endcase
            %} // end-of-switch
          end, %% endfun
          Casefunx1(Casefunx1, 1)
          end;
        %% if-then
        true ->
          atspre_lazy_vt_free(Env0),
          atscc2erl_null
        %% if-else
      end;
    %% if-then
    true ->
      atspre_lazy_vt_free(Env0)
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_length(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret22
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_length,
  f_ats2erlpre_stream_vt_loop_12(Arg0, 0).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_loop_12(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret23
%% var Tmp24
%% var Tmp26
%% var Tmp27
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_loop_12,
  Tmp24 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp24)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      Arg1;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp26 = ?ATSSELcon(Tmp24, 1),
      %% ATSINSfreecon(Tmp24);,
      Tmp27 = ats2erlpre_add_int1_int1(Arg1, 1),
      f_ats2erlpre_stream_vt_loop_12(Tmp26, Tmp27);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream2list_vt(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret28
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream2list_vt,
  f_ats2erlpre_stream_vt_aux_14(Arg0).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_aux_14(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret29
%% var Tmp30
%% var Tmp31
%% var Tmp32
%% var Tmp33
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_aux_14,
  Tmp30 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp30)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      atscc2erl_null;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp31 = ?ATSSELcon(Tmp30, 0),
      Tmp32 = ?ATSSELcon(Tmp30, 1),
      %% ATSINSfreecon(Tmp30);,
      Tmp33 = f_ats2erlpre_stream_vt_aux_14(Tmp32),
      {Tmp31, Tmp33};
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream2list_vt_rev(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret34
%% var Tmp40
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream2list_vt_rev,
  Tmp40 = atscc2erl_null,
  f_ats2erlpre_stream_vt_loop_16(Arg0, Tmp40).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_loop_16(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret35
%% var Tmp36
%% var Tmp37
%% var Tmp38
%% var Tmp39
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_loop_16,
  Tmp36 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp36)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      Arg1;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp37 = ?ATSSELcon(Tmp36, 0),
      Tmp38 = ?ATSSELcon(Tmp36, 1),
      %% ATSINSfreecon(Tmp36);,
      Tmp39 = {Tmp37, Arg1},
      f_ats2erlpre_stream_vt_loop_16(Tmp38, Tmp39);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_append(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret41
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_append,
  f_ats2erlpre_stream_vt_auxmain_18(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_18(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret42
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_18,
  f_ats2erlpre_stream_vt_patsfun_19__closurerize(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_patsfun_19(Env0, Env1, Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret43
%% var Tmp44
%% var Tmp45
%% var Tmp46
%% var Tmp47
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_patsfun_19,
  if
    Arg0 ->
      Tmp44 = ?ATSPMVllazyval_eval(Env0),
      begin
      Casefunx1 =
      fun (Casefun, Tmplab) ->
        %switch(Tmplab) {
        case Tmplab of
          %% ATSbranchseq_beg
          1 ->
          if(?ATSCKptriscons(Tmp44)) -> Casefun(Casefun, 4); true ->
            Casefun(Casefun, 2)
          end;
          2 ->
          ?ATSPMVllazyval_eval(Env1);
          %% ATSbranchseq_end
          %% ATSbranchseq_beg
          3 ->
          Casefun(Casefun, 4);
          4 ->
          Tmp45 = ?ATSSELcon(Tmp44, 0),
          Tmp46 = ?ATSSELcon(Tmp44, 1),
          %% ATSINSfreecon(Tmp44);,
          Tmp47 = f_ats2erlpre_stream_vt_auxmain_18(Tmp46, Env1),
          {Tmp45, Tmp47};
          %% ATSbranchseq_end
          _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
        end %% endcase
        %} // end-of-switch
      end, %% endfun
      Casefunx1(Casefunx1, 1)
      end;
    %% if-then
    true ->
      atspre_lazy_vt_free(Env0),
      atspre_lazy_vt_free(Env1)
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_concat(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret50
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_concat,
  f_ats2erlpre_stream_vt_auxmain_21(Arg0).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_21(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret51
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_21,
  f_ats2erlpre_stream_vt_patsfun_22__closurerize(Arg0).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_patsfun_22(Env0, Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret52
%% var Tmp53
%% var Tmp54
%% var Tmp55
%% var Tmp56
%% var Tmp57
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_patsfun_22,
  if
    Arg0 ->
      Tmp53 = ?ATSPMVllazyval_eval(Env0),
      begin
      Casefunx1 =
      fun (Casefun, Tmplab) ->
        %switch(Tmplab) {
        case Tmplab of
          %% ATSbranchseq_beg
          1 ->
          if(?ATSCKptriscons(Tmp53)) -> Casefun(Casefun, 4); true ->
            Casefun(Casefun, 2)
          end;
          2 ->
          atscc2erl_null;
          %% ATSbranchseq_end
          %% ATSbranchseq_beg
          3 ->
          Casefun(Casefun, 4);
          4 ->
          Tmp54 = ?ATSSELcon(Tmp53, 0),
          Tmp55 = ?ATSSELcon(Tmp53, 1),
          %% ATSINSfreecon(Tmp53);,
          Tmp57 = f_ats2erlpre_stream_vt_auxmain_21(Tmp55),
          Tmp56 = ats2erlpre_stream_vt_append(Tmp54, Tmp57),
          ?ATSPMVllazyval_eval(Tmp56);
          %% ATSbranchseq_end
          _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
        end %% endcase
        %} // end-of-switch
      end, %% endfun
      Casefunx1(Casefunx1, 1)
      end;
    %% if-then
    true ->
      atspre_lazy_vt_free(Env0)
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_map_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret59
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_map_cloptr,
  f_ats2erlpre_stream_vt_auxmain_24(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_24(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret60
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_24,
  f_ats2erlpre_stream_vt_patsfun_25__closurerize(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_patsfun_25(Env0, Env1, Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret61
%% var Tmp62
%% var Tmp63
%% var Tmp64
%% var Tmp65
%% var Tmp66
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_patsfun_25,
  if
    Arg0 ->
      Tmp62 = ?ATSPMVllazyval_eval(Env0),
      begin
      Casefunx1 =
      fun (Casefun, Tmplab) ->
        %switch(Tmplab) {
        case Tmplab of
          %% ATSbranchseq_beg
          1 ->
          if(?ATSCKptriscons(Tmp62)) -> Casefun(Casefun, 4); true ->
            Casefun(Casefun, 2)
          end;
          2 ->
          atscc2erl_null;
          %% ATSbranchseq_end
          %% ATSbranchseq_beg
          3 ->
          Casefun(Casefun, 4);
          4 ->
          Tmp63 = ?ATSSELcon(Tmp62, 0),
          Tmp64 = ?ATSSELcon(Tmp62, 1),
          %% ATSINSfreecon(Tmp62);,
          Tmp65 = ?ATSfunclo_clo(Env1)(Env1, Tmp63),
          Tmp66 = f_ats2erlpre_stream_vt_auxmain_24(Tmp64, Env1),
          {Tmp65, Tmp66};
          %% ATSbranchseq_end
          _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
        end %% endcase
        %} // end-of-switch
      end, %% endfun
      Casefunx1(Casefunx1, 1)
      end;
    %% if-then
    true ->
      atspre_lazy_vt_free(Env0)
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_filter_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret68
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_filter_cloptr,
  f_ats2erlpre_stream_vt_auxmain_27(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_27(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret69
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_27,
  f_ats2erlpre_stream_vt_patsfun_29__closurerize(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxcon_28(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret72
%% var Tmp73
%% var Tmp74
%% var Tmp75
%% var Tmp76
%% var Tmp77
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxcon_28,
  Tmp73 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp73)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      atscc2erl_null;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp74 = ?ATSSELcon(Tmp73, 0),
      Tmp75 = ?ATSSELcon(Tmp73, 1),
      %% ATSINSfreecon(Tmp73);,
      Tmp76 = ?ATSfunclo_clo(Arg1)(Arg1, Tmp74),
      if
        Tmp76 ->
          Tmp77 = f_ats2erlpre_stream_vt_auxmain_27(Tmp75, Arg1),
          {Tmp74, Tmp77};
        %% if-then
        true ->
          f_ats2erlpre_stream_vt_auxcon_28(Tmp75, Arg1)
        %% if-else
      end;
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_patsfun_29(Env0, Env1, Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret70
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_patsfun_29,
  if
    Arg0 ->
      f_ats2erlpre_stream_vt_auxcon_28(Env0, Env1);
    %% if-then
    true ->
      atspre_lazy_vt_free(Env0)
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_exists_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret78
%% var Tmp85
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_exists_cloptr,
  Tmp85 = f_ats2erlpre_stream_vt_loop_31(Arg0, Arg1),
  Tmp85.
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_loop_31(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret79
%% var Tmp80
%% var Tmp81
%% var Tmp82
%% var Tmp83
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_loop_31,
  Tmp80 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp80)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      false;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp81 = ?ATSSELcon(Tmp80, 0),
      Tmp82 = ?ATSSELcon(Tmp80, 1),
      %% ATSINSfreecon(Tmp80);,
      Tmp83 = ?ATSfunclo_clo(Arg1)(Arg1, Tmp81),
      if
        Tmp83 ->
          atspre_lazy_vt_free(Tmp82),
          true;
        %% if-then
        true ->
          f_ats2erlpre_stream_vt_loop_31(Tmp82, Arg1)
        %% if-else
      end;
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_forall_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret86
%% var Tmp93
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_forall_cloptr,
  Tmp93 = f_ats2erlpre_stream_vt_loop_33(Arg0, Arg1),
  Tmp93.
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_loop_33(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret87
%% var Tmp88
%% var Tmp89
%% var Tmp90
%% var Tmp91
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_loop_33,
  Tmp88 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp88)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      true;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp89 = ?ATSSELcon(Tmp88, 0),
      Tmp90 = ?ATSSELcon(Tmp88, 1),
      %% ATSINSfreecon(Tmp88);,
      Tmp91 = ?ATSfunclo_clo(Arg1)(Arg1, Tmp89),
      if
        Tmp91 ->
          f_ats2erlpre_stream_vt_loop_33(Tmp90, Arg1);
        %% if-then
        true ->
          atspre_lazy_vt_free(Tmp90),
          false
        %% if-else
      end;
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_foreach_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_foreach_cloptr,
  f_ats2erlpre_stream_vt_loop_35(Arg0, Arg1),
  Arg1.
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_loop_35(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmp96
%% var Tmp97
%% var Tmp98
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_loop_35,
  Tmp96 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp96)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      ?ATSINSmove_void();
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp97 = ?ATSSELcon(Tmp96, 0),
      Tmp98 = ?ATSSELcon(Tmp96, 1),
      %% ATSINSfreecon(Tmp96);,
      ?ATSfunclo_clo(Arg1)(Arg1, Tmp97),
      f_ats2erlpre_stream_vt_loop_35(Tmp98, Arg1);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_iforeach_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_iforeach_cloptr,
  f_ats2erlpre_stream_vt_loop_37(0, Arg0, Arg1),
  Arg1.
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_loop_37(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmp103
%% var Tmp104
%% var Tmp105
%% var Tmp107
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_loop_37,
  Tmp103 = ?ATSPMVllazyval_eval(Arg1),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp103)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      ?ATSINSmove_void();
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp104 = ?ATSSELcon(Tmp103, 0),
      Tmp105 = ?ATSSELcon(Tmp103, 1),
      %% ATSINSfreecon(Tmp103);,
      ?ATSfunclo_clo(Arg2)(Arg2, Arg0, Tmp104),
      Tmp107 = ats2erlpre_add_int1_int1(Arg0, 1),
      f_ats2erlpre_stream_vt_loop_37(Tmp107, Tmp105, Arg2);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_rforeach_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_rforeach_cloptr,
  f_ats2erlpre_stream_vt_auxmain_39(Arg0, Arg1),
  Arg1.
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_39(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmp111
%% var Tmp112
%% var Tmp113
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_39,
  Tmp111 = ?ATSPMVllazyval_eval(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Tmp111)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      ?ATSINSmove_void();
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp112 = ?ATSSELcon(Tmp111, 0),
      Tmp113 = ?ATSSELcon(Tmp111, 1),
      %% ATSINSfreecon(Tmp111);,
      f_ats2erlpre_stream_vt_auxmain_39(Tmp113, Arg1),
      ?ATSfunclo_clo(Arg1)(Arg1, Tmp112);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
ats2erlpre_stream_vt_tabulate_cloptr(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret116
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_stream_vt_tabulate_cloptr,
  f_ats2erlpre_stream_vt_auxmain_41(0, Arg0).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_auxmain_41(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret117
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_auxmain_41,
  f_ats2erlpre_stream_vt_patsfun_42__closurerize(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_ats2erlpre_stream_vt_patsfun_42(Env0, Env1, Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret118
%% var Tmp119
%% var Tmp120
%% var Tmp121
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_stream_vt_patsfun_42,
  if
    Arg0 ->
      Tmp119 = ?ATSfunclo_clo(Env1)(Env1, Env0),
      Tmp121 = ats2erlpre_add_int1_int1(Env0, 1),
      Tmp120 = f_ats2erlpre_stream_vt_auxmain_41(Tmp121, Env1),
      {Tmp119, Tmp120};
    %% if-then
    true ->
      atscc2erl_void
    %% if-else
  end.
%} // end-of-function

%%%%%%
%%
%% end-of-compilation-unit
%%
%%%%%%
%%%%%%
%%
%% The Erlang code is generated by atscc2erl
%% The starting compilation time is: 2026-10-11: 10h:52m
%%
%%%%%%

%%fun%%
ats2erlpre_int_repeat_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_repeat_cloptr,
  f_ats2erlpre_intrange_loop_1(Arg0, Arg1),
  Arg1.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_1(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmp2
%% var Tmp4
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_1,
  Tmp2 = ats2erlpre_gt_int0_int0(Arg0, 0),
  if
    Tmp2 ->
      ?ATSfunclo_clo(Arg1)(Arg1),
      Tmp4 = ats2erlpre_sub_int0_int0(Arg0, 1),
      f_ats2erlpre_intrange_loop_1(Tmp4, Arg1);
    %% if-then
    true ->
      ?ATSINSmove_void()
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_int_exists_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret6
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_exists_cloptr,
  ats2erlpre_intrange_exists_cloptr(0, Arg0, Arg1).
%} // end-of-function


%%fun%%
ats2erlpre_int_forall_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret7
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_forall_cloptr,
  ats2erlpre_intrange_forall_cloptr(0, Arg0, Arg1).
%} // end-of-function


%%fun%%
ats2erlpre_int_foreach_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_foreach_cloptr,
  ats2erlpre_intrange_foreach_cloptr(0, Arg0, Arg1).
%} // end-of-function


%%fun%%
ats2erlpre_int_rforeach_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_rforeach_cloptr,
  ats2erlpre_intrange_rforeach_cloptr(0, Arg0, Arg1).
%} // end-of-function


%%fun%%
ats2erlpre_int_foldleft_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret10
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_foldleft_cloptr,
  ats2erlpre_intrange_foldleft_cloptr(0, Arg0, Arg1, Arg2).
%} // end-of-function


%%fun%%
ats2erlpre_int_foldright_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret11
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_foldright_cloptr,
  ats2erlpre_intrange_foldright_cloptr(0, Arg0, Arg1, Arg2).
%} // end-of-function


%%fun%%
ats2erlpre_int_list_vt_map_cloptr(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret12
%% var Tmp18
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int_list_vt_map_cloptr,
  Tmp18 = f_ats2erlpre_intrange_aux_9(Arg0, 0, Arg1),
  Tmp18.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_aux_9(Env0, Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret13
%% var Tmp14
%% var Tmp15
%% var Tmp16
%% var Tmp17
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_aux_9,
  Tmp14 = ats2erlpre_lt_int1_int1(Arg0, Env0),
  if
    Tmp14 ->
      Tmp15 = ?ATSfunclo_clo(Arg1)(Arg1, Arg0),
      Tmp17 = ats2erlpre_add_int1_int1(Arg0, 1),
      Tmp16 = f_ats2erlpre_intrange_aux_9(Env0, Tmp17, Arg1),
      {Tmp15, Tmp16};
    %% if-then
    true ->
      atscc2erl_null
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_int2_exists_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret19
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int2_exists_cloptr,
  ats2erlpre_intrange2_exists_cloptr(0, Arg0, 0, Arg1, Arg2).
%} // end-of-function


%%fun%%
ats2erlpre_int2_forall_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret20
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int2_forall_cloptr,
  ats2erlpre_intrange2_forall_cloptr(0, Arg0, 0, Arg1, Arg2).
%} // end-of-function


%%fun%%
ats2erlpre_int2_foreach_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_int2_foreach_cloptr,
  ats2erlpre_intrange2_foreach_cloptr(0, Arg0, 0, Arg1, Arg2).
%} // end-of-function


%%fun%%
ats2erlpre_intrange_exists_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret22
%% var Tmp27
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange_exists_cloptr,
  Tmp27 = f_ats2erlpre_intrange_loop_14(Arg0, Arg1, Arg2),
  Tmp27.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_14(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret23
%% var Tmp24
%% var Tmp25
%% var Tmp26
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_14,
  Tmp24 = ats2erlpre_lt_int0_int0(Arg0, Arg1),
  if
    Tmp24 ->
      Tmp25 = ?ATSfunclo_clo(Arg2)(Arg2, Arg0),
      if
        Tmp25 ->
          true;
        %% if-then
        true ->
          Tmp26 = ats2erlpre_add_int0_int0(Arg0, 1),
          f_ats2erlpre_intrange_loop_14(Tmp26, Arg1, Arg2)
        %% if-else
      end;
    %% if-then
    true ->
      false
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange_forall_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret28
%% var Tmp33
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange_forall_cloptr,
  Tmp33 = f_ats2erlpre_intrange_loop_16(Arg0, Arg1, Arg2),
  Tmp33.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_16(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret29
%% var Tmp30
%% var Tmp31
%% var Tmp32
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_16,
  Tmp30 = ats2erlpre_lt_int0_int0(Arg0, Arg1),
  if
    Tmp30 ->
      Tmp31 = ?ATSfunclo_clo(Arg2)(Arg2, Arg0),
      if
        Tmp31 ->
          Tmp32 = ats2erlpre_add_int0_int0(Arg0, 1),
          f_ats2erlpre_intrange_loop_16(Tmp32, Arg1, Arg2);
        %% if-then
        true ->
          false
        %% if-else
      end;
    %% if-then
    true ->
      true
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange_foreach_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange_foreach_cloptr,
  f_ats2erlpre_intrange_loop_18(Arg0, Arg1, Arg2),
  Arg2.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_18(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmp36
%% var Tmp38
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_18,
  Tmp36 = ats2erlpre_lt_int0_int0(Arg0, Arg1),
  if
    Tmp36 ->
      ?ATSfunclo_clo(Arg2)(Arg2, Arg0),
      Tmp38 = ats2erlpre_add_int0_int0(Arg0, 1),
      f_ats2erlpre_intrange_loop_18(Tmp38, Arg1, Arg2);
    %% if-then
    true ->
      ?ATSINSmove_void()
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange_rforeach_cloptr(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange_rforeach_cloptr,
  f_ats2erlpre_intrange_loop_20(Arg0, Arg1, Arg2),
  Arg2.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_20(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmp42
%% var Tmp44
%% var Tmp45
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_20,
  Tmp42 = ats2erlpre_lt_int0_int0(Arg0, Arg1),
  if
    Tmp42 ->
      Tmp44 = ats2erlpre_sub_int0_int0(Arg1, 1),
      ?ATSfunclo_clo(Arg2)(Arg2, Tmp44),
      Tmp45 = ats2erlpre_sub_int0_int0(Arg1, 1),
      f_ats2erlpre_intrange_loop_20(Arg0, Tmp45, Arg2);
    %% if-then
    true ->
      ?ATSINSmove_void()
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange_foldleft_cloptr(Arg0, Arg1, Arg2, Arg3) ->
%{
%%
%% knd = 0
%% var Tmpret47
%% var Tmp52
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange_foldleft_cloptr,
  Tmp52 = f_ats2erlpre_intrange_loop_22(Arg0, Arg1, Arg2, Arg3),
  Tmp52.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_22(Arg0, Arg1, Arg2, Arg3) ->
%{
%%
%% knd = 0
%% var Tmpret48
%% var Tmp49
%% var Tmp50
%% var Tmp51
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_22,
  Tmp49 = ats2erlpre_lt_int0_int0(Arg0, Arg1),
  if
    Tmp49 ->
      Tmp50 = ats2erlpre_add_int0_int0(Arg0, 1),
      Tmp51 = ?ATSfunclo_clo(Arg3)(Arg3, Arg2, Arg0),
      f_ats2erlpre_intrange_loop_22(Tmp50, Arg1, Tmp51, Arg3);
    %% if-then
    true ->
      Arg2
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange_foldright_cloptr(Arg0, Arg1, Arg2, Arg3) ->
%{
%%
%% knd = 0
%% var Tmpret53
%% var Tmp59
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange_foldright_cloptr,
  Tmp59 = f_ats2erlpre_intrange_loop_24(Arg0, Arg1, Arg2, Arg3),
  Tmp59.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop_24(Arg0, Arg1, Arg2, Arg3) ->
%{
%%
%% knd = 0
%% var Tmpret54
%% var Tmp55
%% var Tmp56
%% var Tmp57
%% var Tmp58
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop_24,
  Tmp55 = ats2erlpre_lt_int0_int0(Arg0, Arg1),
  if
    Tmp55 ->
      Tmp56 = ats2erlpre_sub_int0_int0(Arg1, 1),
      Tmp58 = ats2erlpre_sub_int0_int0(Arg1, 1),
      Tmp57 = ?ATSfunclo_clo(Arg2)(Arg2, Tmp58, Arg3),
      f_ats2erlpre_intrange_loop_24(Arg0, Tmp56, Arg2, Tmp57);
    %% if-then
    true ->
      Arg3
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange2_exists_cloptr(Arg0, Arg1, Arg2, Arg3, Arg4) ->
%{
%%
%% knd = 0
%% var Tmpret60
%% var Tmp69
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange2_exists_cloptr,
  Tmp69 = f_ats2erlpre_intrange_loop1_26(Arg1, Arg2, Arg3, Arg0, Arg4),
  Tmp69.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop1_26(Env0, Env1, Env2, Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret61
%% var Tmp62
%% var Tmp63
%% var Tmp64
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop1_26,
  Tmp62 = ats2erlpre_lt_int0_int0(Arg0, Env0),
  if
    Tmp62 ->
      Tmp63 = f_ats2erlpre_intrange_loop2_27(Env2, Arg0, Env1, Arg1),
      if
        Tmp63 ->
          true;
        %% if-then
        true ->
          Tmp64 = ats2erlpre_add_int0_int0(Arg0, 1),
          f_ats2erlpre_intrange_loop1_26(Env0, Env1, Env2, Tmp64, Arg1)
        %% if-else
      end;
    %% if-then
    true ->
      false
    %% if-else
  end.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop2_27(Env0, Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret65
%% var Tmp66
%% var Tmp67
%% var Tmp68
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop2_27,
  Tmp66 = ats2erlpre_lt_int0_int0(Arg1, Env0),
  if
    Tmp66 ->
      Tmp67 = ?ATSfunclo_clo(Arg2)(Arg2, Arg0, Arg1),
      if
        Tmp67 ->
          true;
        %% if-then
        true ->
          Tmp68 = ats2erlpre_add_int0_int0(Arg1, 1),
          f_ats2erlpre_intrange_loop2_27(Env0, Arg0, Tmp68, Arg2)
        %% if-else
      end;
    %% if-then
    true ->
      false
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange2_forall_cloptr(Arg0, Arg1, Arg2, Arg3, Arg4) ->
%{
%%
%% knd = 0
%% var Tmpret70
%% var Tmp79
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange2_forall_cloptr,
  Tmp79 = f_ats2erlpre_intrange_loop1_29(Arg1, Arg2, Arg3, Arg0, Arg4),
  Tmp79.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop1_29(Env0, Env1, Env2, Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret71
%% var Tmp72
%% var Tmp73
%% var Tmp74
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop1_29,
  Tmp72 = ats2erlpre_lt_int0_int0(Arg0, Env0),
  if
    Tmp72 ->
      Tmp73 = f_ats2erlpre_intrange_loop2_30(Env2, Arg0, Env1, Arg1),
      if
        Tmp73 ->
          Tmp74 = ats2erlpre_add_int0_int0(Arg0, 1),
          f_ats2erlpre_intrange_loop1_29(Env0, Env1, Env2, Tmp74, Arg1);
        %% if-then
        true ->
          false
        %% if-else
      end;
    %% if-then
    true ->
      true
    %% if-else
  end.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop2_30(Env0, Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret75
%% var Tmp76
%% var Tmp77
%% var Tmp78
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop2_30,
  Tmp76 = ats2erlpre_lt_int0_int0(Arg1, Env0),
  if
    Tmp76 ->
      Tmp77 = ?ATSfunclo_clo(Arg2)(Arg2, Arg0, Arg1),
      if
        Tmp77 ->
          Tmp78 = ats2erlpre_add_int0_int0(Arg1, 1),
          f_ats2erlpre_intrange_loop2_30(Env0, Arg0, Tmp78, Arg2);
        %% if-then
        true ->
          false
        %% if-else
      end;
    %% if-then
    true ->
      true
    %% if-else
  end.
%} // end-of-function


%%fun%%
ats2erlpre_intrange2_foreach_cloptr(Arg0, Arg1, Arg2, Arg3, Arg4) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_intrange2_foreach_cloptr,
  f_ats2erlpre_intrange_loop1_32(Arg1, Arg2, Arg3, Arg0, Arg4),
  Arg4.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop1_32(Env0, Env1, Env2, Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmp82
%% var Tmp84
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop1_32,
  Tmp82 = ats2erlpre_lt_int0_int0(Arg0, Env0),
  if
    Tmp82 ->
      f_ats2erlpre_intrange_loop2_33(Env2, Arg0, Env1, Arg1),
      Tmp84 = ats2erlpre_add_int0_int0(Arg0, 1),
      f_ats2erlpre_intrange_loop1_32(Env0, Env1, Env2, Tmp84, Arg1);
    %% if-then
    true ->
      ?ATSINSmove_void()
    %% if-else
  end.
%} // end-of-function


%%fun%%
f_ats2erlpre_intrange_loop2_33(Env0, Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmp86
%% var Tmp88
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__ats2erlpre_intrange_loop2_33,
  Tmp86 = ats2erlpre_lt_int0_int0(Arg1, Env0),
  if
    Tmp86 ->
      ?ATSfunclo_clo(Arg2)(Arg2, Arg0, Arg1),
      Tmp88 = ats2erlpre_add_int0_int0(Arg1, 1),
      f_ats2erlpre_intrange_loop2_33(Env0, Arg0, Tmp88, Arg2);
    %% if-then
    true ->
      ?ATSINSmove_void()
    %% if-else
  end.
%} // end-of-function

%%%%%%
%%
%% end-of-compilation-unit
%%
%%%%%%

% ****** ****** %

% end of [output/libatscc2erl_all.hrl] %
