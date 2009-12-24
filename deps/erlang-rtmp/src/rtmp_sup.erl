-module(rtmp_sup).
-author(max@maxidoors.ru).

-behaviour(supervisor).

-export ([init/1,start_link/0, start_rtmpt/2]).

%%--------------------------------------------------------------------
%% @spec () -> any()
%% @doc A startup function for whole supervisor. Started by application
%% @end 
%%--------------------------------------------------------------------
-spec start_link() -> {'error',_} | {'ok',pid()}.
start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_rtmpt(SessionID, IP) -> supervisor:start_child(rtmpt_session, [SessionID, IP]).


init([rtmp_socket]) ->
  {ok,
    {_SupFlags = {simple_one_for_one, 5, 60},
      [
        % MediaEntry
        {   undefined,                               % Id       = internal id
            {rtmp_socket,start_link,[]},             % StartFun = {M, F, A}
            temporary,                               % Restart  = permanent | transient | temporary
            2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
            worker,                                  % Type     = worker | supervisor
            [rtmp_socket]                            % Modules  = [Module] | dynamic
        }
      ]
    }
  };

init([rtmpt_session]) ->
  {ok,
    {_SupFlags = {simple_one_for_one, 5, 60},
      [
        % MediaEntry
        {   undefined,                               % Id       = internal id
            {rtmpt_session,start_link,[]},             % StartFun = {M, F, A}
            temporary,                               % Restart  = permanent | transient | temporary
            2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
            worker,                                  % Type     = worker | supervisor
            [rtmpt_session]                            % Modules  = [Module] | dynamic
        }
      ]
    }
  };


init([]) ->
  Supervisors = [
    {rtmpt_sessions_sup,                       % Id       = internal id
      {rtmpt_sessions,start_link,[]},          % StartFun = {M, F, A}
      permanent,                               % Restart  = permanent | transient | temporary
      2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
      worker,                                  % Type     = worker | supervisor
      [rtmpt_sessions]                         % Modules  = [Module] | dynamic
    },
    {rtmpt_session_sup,
      {supervisor,start_link,[{local, rtmpt_session_sup}, ?MODULE, [rtmpt_session]]},
      permanent,                               % Restart  = permanent | transient | temporary
      infinity,                                % Shutdown = brutal_kill | int() >= 0 | infinity
      supervisor,                              % Type     = worker | supervisor
      []                                       % Modules  = [Module] | dynamic
    },
    {rtmp_socket_sup,
      {supervisor,start_link,[{local, rtmp_socket_sup}, ?MODULE, [rtmp_socket]]},
      permanent,                               % Restart  = permanent | transient | temporary
      infinity,                                % Shutdown = brutal_kill | int() >= 0 | infinity
      supervisor,                              % Type     = worker | supervisor
      []                                       % Modules  = [Module] | dynamic
    }
  ],
  
  {ok, {{one_for_one, 5, 60}, Supervisors}}.
