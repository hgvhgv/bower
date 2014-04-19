% Bower - a frontend for the Notmuch email system
% Copyright (C) 2011 Peter Wang

:- module copious_output.
:- interface.

:- import_module io.
:- import_module maybe.

:- import_module data.
:- import_module prog_config.
:- import_module quote_arg.

:- pred expand_part(prog_config::in, message_id::in, int::in,
    maybe(command_prefix)::in, maybe_error(string)::out, io::di, io::uo)
    is det.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.

:- import_module list.
:- import_module string.

:- import_module call_system.
:- import_module prog_config.
:- import_module quote_arg.

%-----------------------------------------------------------------------------%

expand_part(ProgConfig, MessageId, PartId, MaybeFilterCommand, Res, !IO) :-
    get_notmuch_command(ProgConfig, Notmuch),
    make_quoted_command(Notmuch, [
        "show", "--format=raw", "--part=" ++ from_int(PartId),
        message_id_to_search_term(MessageId)
    ], ShowCommand),
    (
        MaybeFilterCommand = yes(Filter),
        make_quoted_command(Filter, [], FilterCommand),
        Command = ShowCommand ++ " | " ++ FilterCommand
    ;
        MaybeFilterCommand = no,
        Command = ShowCommand
    ),
    ErrorLimit = yes(100),
    call_system_capture_stdout(Command, ErrorLimit, CallRes, !IO),
    (
        CallRes = ok(ContentString),
        Res = ok(ContentString)
    ;
        CallRes = error(Error),
        Res = error(io.error_message(Error))
    ).

%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sts=4 sw=4 et
