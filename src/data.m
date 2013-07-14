% Bower - a frontend for the Notmuch email system
% Copyright (C) 2011 Peter Wang

:- module data.
:- interface.

:- import_module cord.
:- import_module list.
:- import_module map.
:- import_module maybe.
:- import_module set.

%-----------------------------------------------------------------------------%

:- type thread
    --->    thread(
                t_id        :: thread_id,
                t_timestamp :: int,
                t_authors   :: string,
                t_subject   :: string,
                t_tags      :: set(tag),
                t_matched   :: int,
                t_total     :: int
            ).

:- type thread_id
    --->    thread_id(string).

:- type message
    --->    message(
                m_id        :: message_id,
                m_timestamp :: int,
                m_headers   :: headers,
                m_tags      :: set(tag),
                m_body      :: list(part),
                m_replies   :: list(message)
            ).

:- type message_id
    --->    message_id(string).

:- type headers
    --->    headers(
                % Technically, header fields.
                h_date          :: header_value,
                h_from          :: header_value,
                h_to            :: header_value,
                h_cc            :: header_value,
                h_bcc           :: header_value,
                h_subject       :: header_value,
                h_replyto       :: header_value,
                h_references    :: header_value,
                h_inreplyto     :: header_value,
                % XXX should use a distinct type for header field names
                % for they are case-insensitive
                h_rest          :: map(string, header_value)
            ).

:- type header_value
    --->    header_value(string)
            % Most header values.
    ;       decoded_unstructured(string).
            % An unstructured field that may contain RFC 2047 encoded-words,
            % which we keep in decoded form.

:- type tag
    --->    tag(string).

:- type part
    --->    part(
                pt_msgid        :: message_id,
                pt_part         :: int,
                pt_type         :: string,
                pt_content      :: part_content,
                pt_filename     :: maybe(string),
                pt_encoding     :: maybe(string),
                pt_content_len  :: maybe(int)
            ).

:- type part_content
    --->    text(string)
    ;       subparts(list(part))
    ;       encapsulated_messages(list(encapsulated_message))
    ;       unsupported.

:- type encapsulated_message
    --->    encapsulated_message(
                em_headers      :: headers,
                em_body         :: list(part)
            ).

%-----------------------------------------------------------------------------%

:- func thread_id_to_search_term(thread_id) = string.

:- func message_id_to_search_term(message_id) = string.

:- func init_headers = headers.

:- pred empty_header_value(header_value::in) is semidet.

:- func header_value_string(header_value) = string.

:- pred tag_to_string(tag::in, string::out) is det.

:- pred snoc(T::in, cord(T)::in, cord(T)::out) is det.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.

:- import_module map.
:- import_module string.

%-----------------------------------------------------------------------------%

thread_id_to_search_term(thread_id(Id)) = "thread:" ++ Id.

message_id_to_search_term(message_id(Id)) = "id:" ++ Id.

init_headers = Headers :-
    Empty = header_value(""),
    Headers = headers(Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty,
        Empty, map.init).

empty_header_value(header_value("")).
empty_header_value(decoded_unstructured("")).

header_value_string(header_value(S)) = S.
header_value_string(decoded_unstructured(S)) = S.

tag_to_string(tag(String), String).

snoc(X, C, snoc(C, X)).

%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sts=4 sw=4 et