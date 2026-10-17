%%
%% Time of Generation:
%% Sun Oct 11 10:57:48 AM +04 2026
%%

%%%%%%
%%
%% Session-typed channels
%%
%%%%%%
%%
%% Author: Hongwei Xi
%% Authoremail: gmhwxiATgmailDOTcom
%%
%% Start time: July, 2015
%%
%%%%%%
%%
%% HX-2015-07:
%% A serious limitation with this implementation:
%% it is unable to support chanposneg_link efficiently
%%
%%%%%%
%%
%% A positive channel is a pid: Chpos
%% A negative channel is a pair of pids: {Chpos, Chneg}
%%
%%%%%%
%%
libats2erl_session_chanpos_send
  (Chpos, X) -> Chpos ! {self(), X}.
libats2erl_session_channeg_recv
  ({Chpos, Chneg}, X) -> Chneg ! {Chpos, X}.
%%
%%%%%%
%%
libats2erl_session_chanpos_recv
  (Chpos) -> receive {Chpos, X} -> X end.
libats2erl_session_channeg_send
  ({Chpos, Chneg}) ->
  Chpos ! {self()}, receive {Chneg, X} -> X end.
%%
%%%%%%
%%
libats2erl_session_chanpos_nil_wait(Chpos) ->
  receive {Chpos, libats2erl_session_channeg_close} -> libats2erl_session_channeg_close end.
libats2erl_session_channeg_nil_close({Chpos, Chneg}) ->
  Chneg ! {Chpos, libats2erl_session_channeg_close}, Chpos ! libats2erl_session_chanpos_xfer_close.
%%
%%%%%%
%%
libats2erl_session_chanpos_xfer() ->
  receive
    {Client} ->
    receive
      ChposX = {_Chpos, _X} -> Client ! ChposX, libats2erl_session_chanpos_xfer()
    end;
    X = libats2erl_session_chanpos_xfer_close -> X
  end.
%%
%%%%%%
%%
libats2erl_session_chanposneg_link
  (Chpos1, Chposneg2) ->
  spawn(
    ?MODULE
  , libats2erl_session_chanposneg_link_np
  , [Chpos1, self(), Chposneg2]
  ), %% spawn
  libats2erl_session_chanposneg_link_pn(Chpos1, Chposneg2).
%%
libats2erl_session_chanposneg_link_pn
  (Chpos1, Chposneg2) ->
%%
%%io:format("libats2erl_session_chanposneg_link_pn: Chpos1 = ~p~n", [Chpos1]),
%%io:format("libats2erl_session_chanposneg_link_pn: Chposneg2 = ~p~n", [Chposneg2]),
%%
  X = libats2erl_session_chanpos_recv(Chpos1),
%%
%%io:format("libats2erl_session_chanposneg_link_pn: X = ~p~n", [X]),
%%
  {Chpos2, Chneg2} = Chposneg2,
  if
    (X=:=libats2erl_session_channeg_close) ->
      Chpos1 ! libats2erl_session_chanpos_xfer_close,
      Chpos2 ! {Chneg2, libats2erl_session_channeg_close};
    true ->
      Chneg2 ! {Chpos2, X},
      libats2erl_session_chanposneg_link_pn(Chpos1, Chposneg2)
  end.
%%
libats2erl_session_chanposneg_link_np
  (Chpos1, Chneg1, Chposneg2) ->
%%
%%io:format("libats2erl_session_chanposneg_link_np: Chpos1 = ~p~n", [Chpos1]),
%%io:format("libats2erl_session_chanposneg_link_np: Chneg1 = ~p~n", [Chneg1]),
%%io:format("libats2erl_session_chanposneg_link_np: Chposneg2 = ~p~n", [Chposneg2]),
%%
  X = libats2erl_session_channeg_send(Chposneg2),
%%
%%io:format("libats2erl_session_chanposneg_link_np: X = ~p~n", [X]),
%%
  if
    (X =:=libats2erl_session_channeg_close) ->
      libats2erl_session_channeg_nil_close(Chposneg2);
    true ->
      Chpos1 ! {Chneg1, X},
      libats2erl_session_chanposneg_link_np(Chpos1, Chneg1, Chposneg2)
  end.
%%
%%%%%%
%%
libats2erl_session_channeg_create
  (Fserv) ->
  Chpos = spawn(?MODULE, libats2erl_session_chanpos_xfer, []),
  Chneg = spawn(?MODULE, ats2erlpre_cloref1_app, [Fserv, Chpos]),
%%
%%io:format("libats2erl_session_channeg_create: Chpos = ~p~n", [Chpos]),
%%io:format("libats2erl_session_channeg_create: Chneg = ~p~n", [Chneg]),
%%
  {Chpos, Chneg}.
%%
libats2erl_session_channeg_createnv
  (Fserv, Env) ->
  Chpos = spawn(?MODULE, libats2erl_session_chanpos_xfer, []),
  Chneg = spawn(?MODULE, ats2erlpre_cloref2_app, [Fserv, Env, Chpos]),
%%
%%io:format("libats2erl_session_channeg_createnv: Chpos = ~p~n", [Chpos]),
%%io:format("libats2erl_session_channeg_createnv: Chneg = ~p~n", [Chneg]),
%%
  {Chpos, Chneg}.
%%
%%%%%%
%%
%% HX-2015-07-04:
%% This is all for internal use!
%%
libats2erl_session_chanpos2_send
  (Chpos, X) ->
  libats2erl_session_chanpos_send(Chpos, X).
libats2erl_session_channeg2_recv
  (Chposneg, X) ->
  libats2erl_session_channeg_recv(Chposneg, X).
%%
libats2erl_session_chanpos2_recv
  (Chpos) -> libats2erl_session_chanpos_recv(Chpos).
libats2erl_session_channeg2_send
  (Chposneg) -> libats2erl_session_channeg_send(Chposneg).
%%
%%%%%%
%%
%% Service creation and request
%%
%%%%%%
%%
libats2erl_session_chansrvc_create
  (Fserv) ->
  spawn(
    ?MODULE
  , libats2erl_session_chansrvc_create_server, [Fserv]
  ). %% spawn
libats2erl_session_chansrvc_create_server
  (Fserv) ->
  receive
    {Client} ->
      Chposneg = libats2erl_session_channeg_create(Fserv),
      Client ! Chposneg,
      libats2erl_session_chansrvc_create_server(Fserv)
  end.
%%
libats2erl_session_chansrvc_request
  (Chsrvc) ->
  Chsrvc ! {self()},
  receive Chposneg = {_Chpos, _Chneg} -> Chposneg end.
%%
%% HX: For convenience: chansrvc2
%%
libats2erl_session_chansrvc2_create
  (Fserv) ->
  spawn(
    ?MODULE
  , libats2erl_session_chansrvc2_create_server, [Fserv]
  ). %% spawn
libats2erl_session_chansrvc2_create_server
  (Fserv) ->
  receive
    {Client, Env} ->
      Chposneg =
      libats2erl_session_channeg_createnv(Fserv, Env),
      Client ! Chposneg,
      libats2erl_session_chansrvc2_create_server(Fserv)
  end.
%%
libats2erl_session_chansrvc2_request
  (Env, Chsrvc) ->
  Chsrvc ! {self(), Env},
  receive Chposneg = {_Chpos, _Chneg} -> Chposneg end.
%%
%% HX: For registering (persistent) services
%%
libats2erl_session_chansrvc_register(Name, Ch) -> register(Name, Ch).
libats2erl_session_chansrvc2_register(Name, Ch) -> register(Name, Ch).
%%
%%%%%%

%%%%%% end of [basis_cats.hrl] %%%%%%
%%%%%%
%%
%% The Erlang code is generated by atscc2erl
%% The starting compilation time is: 2026-10-11: 10h:57m
%%
%%%%%%

%%fun%%
f_libats2erl_session_sslist_patsfun_5__closurerize(XEnv0) -> 
%{
  {fun({_, Cenv1}, XArg0) -> f_libats2erl_session_sslist_patsfun_5(Cenv1, XArg0) end, XEnv0}.
%}


%%fun%%
libats2erl_session_chanpos_list_nil(Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_chanpos_list_nil,
  libats2erl_session_chanpos2_send(Arg0, 0).
%} // end-of-function


%%fun%%
libats2erl_session_chanpos_list_cons(Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_chanpos_list_cons,
  libats2erl_session_chanpos2_send(Arg0, 1).
%} // end-of-function


%%fun%%
libats2erl_session_channeg_list(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret2
%% var Tmp3
%% var Tmp4
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_channeg_list,
  Tmp3 = libats2erl_session_channeg2_send(Arg0),
  Tmp4 = ats2erlpre_eq_int0_int0(Tmp3, 0),
  if
    Tmp4 ->
      0;
    %% if-then
    true ->
      1
    %% if-else
  end.
%} // end-of-function


%%fun%%
libats2erl_session_list2sslist_vt(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret5
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list2sslist_vt,
  libats2erl_session_channeg_create(f_libats2erl_session_sslist_patsfun_5__closurerize(Arg0)).
%} // end-of-function


%%fun%%
f_libats2erl_session_sslist_fserv_4(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmp7
%% var Tmp8
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_sslist_fserv_4,
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Arg1)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      libats2erl_session_chanpos_list_nil(Arg0),
      libats2erl_session_chanpos_nil_wait(Arg0);
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp7 = ?ATSSELcon(Arg1, 0),
      Tmp8 = ?ATSSELcon(Arg1, 1),
      %% ATSINSfreecon(Arg1);,
      libats2erl_session_chanpos_list_cons(Arg0),
      libats2erl_session_chanpos_send(Arg0, Tmp7),
      f_libats2erl_session_sslist_fserv_4(Arg0, Tmp8);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
f_libats2erl_session_sslist_patsfun_5(Env0, Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_sslist_patsfun_5,
  f_libats2erl_session_sslist_fserv_4(Arg0, Env0).
%} // end-of-function


%%fun%%
libats2erl_session_sslist2list_vt(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret13
%% var Tmp19
%% var Tmp20
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_sslist2list_vt,
  Tmp20 = atscc2erl_null,
  Tmp19 = f_libats2erl_session_sslist_loop_7(Arg0, Tmp20),
  ats2erlpre_list_vt_reverse(Tmp19).
%} // end-of-function


%%fun%%
f_libats2erl_session_sslist_loop_7(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret14
%% var Tmp15
%% var Tmp17
%% var Tmp18
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_sslist_loop_7,
  Tmp15 = libats2erl_session_channeg_list(Arg0),
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(not(?ATSCKpat_con0(Tmp15, 0))) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      libats2erl_session_channeg_nil_close(Arg0),
      Arg1;
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp17 = libats2erl_session_channeg_send(Arg0),
      Tmp18 = {Tmp17, Arg1},
      f_libats2erl_session_sslist_loop_7(Arg0, Tmp18);
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
%% The starting compilation time is: 2026-10-11: 10h:57m
%%
%%%%%%

%%fun%%
libats2erl_session_chanpos_list(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret0
%% var Tmp1
%% var Tmp2
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_chanpos_list,
  Tmp1 = libats2erl_session_chanpos2_recv(Arg0),
  Tmp2 = ats2erlpre_eq_int0_int0(Tmp1, 0),
  if
    Tmp2 ->
      0;
    %% if-then
    true ->
      1
    %% if-else
  end.
%} // end-of-function


%%fun%%
libats2erl_session_channeg_list_nil(Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_channeg_list_nil,
  libats2erl_session_channeg2_recv(Arg0, 0).
%} // end-of-function


%%fun%%
libats2erl_session_channeg_list_cons(Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_channeg_list_cons,
  libats2erl_session_channeg2_recv(Arg0, 1).
%} // end-of-function

%%%%%%
%%
%% end-of-compilation-unit
%%
%%%%%%
%%%%%%
%%
%% The Erlang code is generated by atscc2erl
%% The starting compilation time is: 2026-10-11: 10h:56m
%%
%%%%%%

%%fun%%
f_libats2erl_session_ssarray_patsfun_4__closurerize(XEnv0) -> 
%{
  {fun({_, Cenv1}, XArg0) -> f_libats2erl_session_ssarray_patsfun_4(Cenv1, XArg0) end, XEnv0}.
%}


%%fun%%
f_057_home_057_msorc_057_install_057_devel_057_lang_057_ats_057_ATS_055_Postiats_057_contrib_057_CATS_055_atscc2erl_057_TEST_057_Sessiontype_057_SATS_057_array_056_sats__chanpos_arrsz(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_chanpos_arrsz,
  libats2erl_session_chanpos_send(Arg0, Arg1).
%} // end-of-function


%%fun%%
f_057_home_057_msorc_057_install_057_devel_057_lang_057_ats_057_ATS_055_Postiats_057_contrib_057_CATS_055_atscc2erl_057_TEST_057_Sessiontype_057_SATS_057_array_056_sats__channeg_arrsz(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret1
%% var Tmp2
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_channeg_arrsz,
  Tmp2 = libats2erl_session_channeg_send(Arg0),
  Tmp2.
%} // end-of-function


%%fun%%
f_057_home_057_msorc_057_install_057_devel_057_lang_057_ats_057_ATS_055_Postiats_057_contrib_057_CATS_055_atscc2erl_057_TEST_057_Sessiontype_057_SATS_057_array_056_sats__list2ssarray_vt(Arg0) ->
%{
%%
%% knd = 0
%% var Tmpret3
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_list2ssarray_vt,
  libats2erl_session_channeg_create(f_libats2erl_session_ssarray_patsfun_4__closurerize(Arg0)).
%} // end-of-function


%%fun%%
f_libats2erl_session_ssarray_fserv_3(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmp5
%% var Tmp6
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_ssarray_fserv_3,
  begin
  Casefunx1 =
  fun (Casefun, Tmplab) ->
    %switch(Tmplab) {
    case Tmplab of
      %% ATSbranchseq_beg
      1 ->
      if(?ATSCKptriscons(Arg1)) -> Casefun(Casefun, 4); true ->
        Casefun(Casefun, 2)
      end;
      2 ->
      libats2erl_session_chanpos_nil_wait(Arg0);
      %% ATSbranchseq_end
      %% ATSbranchseq_beg
      3 ->
      Casefun(Casefun, 4);
      4 ->
      Tmp5 = ?ATSSELcon(Arg1, 0),
      Tmp6 = ?ATSSELcon(Arg1, 1),
      %% ATSINSfreecon(Arg1);,
      libats2erl_session_chanpos_send(Arg0, Tmp5),
      f_libats2erl_session_ssarray_fserv_3(Arg0, Tmp6);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
f_libats2erl_session_ssarray_patsfun_4(Env0, Arg0) ->
%{
%%
%% knd = 0
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_ssarray_patsfun_4,
  f_libats2erl_session_ssarray_fserv_3(Arg0, Env0).
%} // end-of-function


%%fun%%
f_057_home_057_msorc_057_install_057_devel_057_lang_057_ats_057_ATS_055_Postiats_057_contrib_057_CATS_055_atscc2erl_057_TEST_057_Sessiontype_057_SATS_057_array_056_sats__ssarray2list_vt(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret9
%% var Tmp10
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_ssarray2list_vt,
  Tmp10 = f_057_home_057_msorc_057_install_057_devel_057_lang_057_ats_057_ATS_055_Postiats_057_contrib_057_CATS_055_atscc2erl_057_TEST_057_Sessiontype_057_SATS_057_array_056_sats__channeg_array_takeout_list(Arg0, Arg1),
  libats2erl_session_channeg_nil_close(Arg0),
  Tmp10.
%} // end-of-function


%%fun%%
f_057_home_057_msorc_057_install_057_devel_057_lang_057_ats_057_ATS_055_Postiats_057_contrib_057_CATS_055_atscc2erl_057_TEST_057_Sessiontype_057_SATS_057_array_056_sats__channeg_array_takeout_list(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret12
%% var Tmp22
%% var Tmp23
%% var Tmp24
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab_channeg_array_takeout_list,
  Tmp23 = atscc2erl_null,
  Tmp22 = f_libats2erl_session_ssarray_loop_8(Arg0, Arg1, Tmp23),
  Tmp24 = atscc2erl_null,
  f_libats2erl_session_ssarray_revapp_7(Tmp22, Tmp24).
%} // end-of-function


%%fun%%
f_libats2erl_session_ssarray_revapp_7(Arg0, Arg1) ->
%{
%%
%% knd = 0
%% var Tmpret13
%% var Tmp14
%% var Tmp15
%% var Tmp16
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_ssarray_revapp_7,
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
      Tmp14 = ?ATSSELcon(Arg0, 0),
      Tmp15 = ?ATSSELcon(Arg0, 1),
      %% ATSINSfreecon(Arg0);,
      Tmp16 = {Tmp14, Arg1},
      f_libats2erl_session_ssarray_revapp_7(Tmp15, Tmp16);
      %% ATSbranchseq_end
      _ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)
    end %% endcase
    %} // end-of-switch
  end, %% endfun
  Casefunx1(Casefunx1, 1)
  end.
%} // end-of-function


%%fun%%
f_libats2erl_session_ssarray_loop_8(Arg0, Arg1, Arg2) ->
%{
%%
%% knd = 0
%% var Tmpret17
%% var Tmp18
%% var Tmp19
%% var Tmp20
%% var Tmp21
%% var Tmplab, Tmplab_erl
%%
  %% __patsflab__libats2erl_session_ssarray_loop_8,
  Tmp18 = ats2erlpre_gt_int1_int1(Arg1, 0),
  if
    Tmp18 ->
      Tmp19 = libats2erl_session_channeg_send(Arg0),
      Tmp20 = ats2erlpre_sub_int1_int1(Arg1, 1),
      Tmp21 = {Tmp19, Arg2},
      f_libats2erl_session_ssarray_loop_8(Arg0, Tmp20, Tmp21);
    %% if-then
    true ->
      Arg2
    %% if-else
  end.
%} // end-of-function

%%%%%%
%%
%% end-of-compilation-unit
%%
%%%%%%

%% ****** ****** %%

%% end of [mylibats2erl1_all.hrl] %%
