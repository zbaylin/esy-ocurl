open Configurator.V1
open C_define
open Flags

type os = Android | IOS | Linux | Mac | Windows

let detect_system_header =
  {|
  #if __APPLE__
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
      #define PLATFORM_NAME "ios"
    #else
      #define PLATFORM_NAME "mac"
    #endif
  #elif __linux__
    #if __ANDROID__
      #define PLATFORM_NAME "android"
    #else
      #define PLATFORM_NAME "linux"
    #endif
  #elif WIN32
    #define PLATFORM_NAME "windows"
  #endif
|}

let get_os t =
  let header =
    let file = Filename.temp_file "discover" "os.h" in
    let fd = open_out file in
    output_string fd detect_system_header;
    close_out fd;
    file
  in
  let platform = import t ~includes:[ header ] [ ("PLATFORM_NAME", String) ] in
  match platform with
  | [ (_, String "android") ] -> Android
  | [ (_, String "ios") ] -> IOS
  | [ (_, String "linux") ] -> Linux
  | [ (_, String "mac") ] -> Mac
  | [ (_, String "windows") ] -> Windows
  | _ -> failwith "Unknown OS"

let ccopt s = [ "-ccopt"; s ]

let cclib s = [ "-cclib"; s ]

let flags os =
  match os with Windows | Linux | Mac -> [] @ cclib "-lcurl" | _ -> []

let c_flags t =
  let os = get_os t in
  match os with
  | Linux -> (
      match Pkg_config.get t with
      | None -> failwith "pkg-config not found"
      | Some pc -> (
          match Pkg_config.query pc ~package:"libcurl" with
          | None -> failwith "pkg-config could not find libcurl"
          | Some deps -> [] @ [ "-DHAVE_CONFIG_H" ] @ [ "-fPIC" ] @ deps.cflags)
      )
  | Mac -> [] @ [ "-DHAVE_CONFIG_H" ]
  | Windows ->
      [] @ [ "-DHAVE_CONFIG_H" ] @ [ "-I" ^ Sys.getenv "CURL_INCLUDE_PATH" ]
  | _ -> []

let declarations =
  [
    "CURLE_ABORTED_BY_CALLBACK";
    "CURLE_AGAIN";
    "CURLE_BAD_CALLING_ORDER";
    "CURLE_BAD_CONTENT_ENCODING";
    "CURLE_BAD_DOWNLOAD_RESUME";
    "CURLE_BAD_FUNCTION_ARGUMENT";
    "CURLE_BAD_PASSWORD_ENTERED";
    "CURLE_CONV_FAILED";
    "CURLE_CONV_REQD";
    "CURLE_COULDNT_CONNECT";
    "CURLE_COULDNT_RESOLVE_HOST";
    "CURLE_COULDNT_RESOLVE_PROXY";
    "CURLE_FAILED_INIT";
    "CURLE_FILESIZE_EXCEEDED";
    "CURLE_FILE_COULDNT_READ_FILE";
    "CURLE_FTP_ACCESS_DENIED";
    "CURLE_FTP_CANT_GET_HOST";
    "CURLE_FTP_CANT_RECONNECT";
    "CURLE_FTP_COULDNT_GET_SIZE";
    "CURLE_FTP_COULDNT_RETR_FILE";
    "CURLE_FTP_COULDNT_SET_ASCII";
    "CURLE_FTP_COULDNT_SET_BINARY";
    "CURLE_FTP_COULDNT_STOR_FILE";
    "CURLE_FTP_COULDNT_USE_REST";
    "CURLE_FTP_PORT_FAILED";
    "CURLE_FTP_QUOTE_ERROR";
    "CURLE_FTP_SSL_FAILED";
    "CURLE_FTP_USER_PASSWORD_INCORRECT";
    "CURLE_FTP_WEIRD_227_FORMAT";
    "CURLE_FTP_WEIRD_PASS_REPLY";
    "CURLE_FTP_WEIRD_PASV_REPLY";
    "CURLE_FTP_WEIRD_SERVER_REPLY";
    "CURLE_FTP_WEIRD_USER_REPLY";
    "CURLE_FTP_WRITE_ERROR";
    "CURLE_FUNCTION_NOT_FOUND";
    "CURLE_GOT_NOTHING";
    "CURLE_HTTP_POST_ERROR";
    "CURLE_HTTP_RANGE_ERROR";
    "CURLE_HTTP_RETURNED_ERROR";
    "CURLE_INTERFACE_FAILED";
    "CURLE_LDAP_CANNOT_BIND";
    "CURLE_LDAP_INVALID_URL";
    "CURLE_LDAP_SEARCH_FAILED";
    "CURLE_LIBRARY_NOT_FOUND";
    "CURLE_LOGIN_DENIED";
    "CURLE_MALFORMAT_USER";
    "CURLE_OPERATION_TIMEOUTED";
    "CURLE_OUT_OF_MEMORY";
    "CURLE_PARTIAL_FILE";
    "CURLE_READ_ERROR";
    "CURLE_RECV_ERROR";
    "CURLE_REMOTE_DISK_FULL";
    "CURLE_REMOTE_FILE_EXISTS";
    "CURLE_REMOTE_FILE_NOT_FOUND";
    "CURLE_SEND_ERROR";
    "CURLE_SEND_FAIL_REWIND";
    "CURLE_SHARE_IN_USE";
    "CURLE_SSH";
    "CURLE_SSL_CACERT";
    "CURLE_SSL_CACERT_BADFILE";
    "CURLE_SSL_CERTPROBLEM";
    "CURLE_SSL_CIPHER";
    "CURLE_SSL_CONNECT_ERROR";
    "CURLE_SSL_ENGINE_INITFAILED";
    "CURLE_SSL_ENGINE_NOTFOUND";
    "CURLE_SSL_ENGINE_SETFAILED";
    "CURLE_SSL_PEER_CERTIFICATE";
    "CURLE_SSL_SHUTDOWN_FAILED";
    "CURLE_TELNET_OPTION_SYNTAX";
    "CURLE_TFTP_ILLEGAL";
    "CURLE_TFTP_NOSUCHUSER";
    "CURLE_TFTP_NOTFOUND";
    "CURLE_TFTP_PERM";
    "CURLE_TFTP_UNKNOWNID";
    "CURLE_TOO_MANY_REDIRECTS";
    "CURLE_UNKNOWN_TELNET_OPTION";
    "CURLE_UNSUPPORTED_PROTOCOL";
    "CURLE_URL_MALFORMAT";
    "CURLE_URL_MALFORMAT_USER";
    "CURLE_WRITE_ERROR";
    "CURLINFO_CERTINFO";
    "CURLINFO_CONDITION_UNMET";
    "CURLINFO_CONNECT_TIME";
    "CURLINFO_CONTENT_LENGTH_DOWNLOAD";
    "CURLINFO_CONTENT_LENGTH_UPLOAD";
    "CURLINFO_CONTENT_TYPE";
    "CURLINFO_COOKIELIST";
    "CURLINFO_EFFECTIVE_URL";
    "CURLINFO_FILETIME";
    "CURLINFO_FTP_ENTRY_PATH";
    "CURLINFO_HEADER_SIZE";
    "CURLINFO_HTTPAUTH_AVAIL";
    "CURLINFO_HTTP_CONNECTCODE";
    "CURLINFO_LASTSOCKET";
    "CURLINFO_LOCAL_IP";
    "CURLINFO_LOCAL_PORT";
    "CURLINFO_NAMELOOKUP_TIME";
    "CURLINFO_NUM_CONNECTS";
    "CURLINFO_OS_ERRNO";
    "CURLINFO_PRETRANSFER_TIME";
    "CURLINFO_PRIMARY_IP";
    "CURLINFO_PROXYAUTH_AVAIL";
    "CURLINFO_REDIRECT_COUNT";
    "CURLINFO_REDIRECT_TIME";
    "CURLINFO_REDIRECT_URL";
    "CURLINFO_REQUEST_SIZE";
    "CURLINFO_RESPONSE_CODE";
    "CURLINFO_SIZE_DOWNLOAD";
    "CURLINFO_SIZE_UPLOAD";
    "CURLINFO_SPEED_DOWNLOAD";
    "CURLINFO_SPEED_UPLOAD";
    "CURLINFO_SSL_ENGINES";
    "CURLINFO_SSL_VERIFYRESULT";
    "CURLINFO_STARTTRANSFER_TIME";
    "CURLINFO_TOTAL_TIME";
    "CURLMOPT_MAXCONNECTS";
    "CURLMOPT_MAX_HOST_CONNECTIONS";
    "CURLMOPT_MAX_PIPELINE_LENGTH";
    "CURLMOPT_PIPELINING";
    "CURLMOPT_SOCKETDATA";
    "CURLMOPT_SOCKETFUNCTION";
    "CURLMOPT_TIMERDATA";
    "CURLMOPT_TIMERFUNCTION";
    "CURLOPT_AUTOREFERER";
    "CURLOPT_BUFFERSIZE";
    "CURLOPT_CAINFO";
    "CURLOPT_CAPATH";
    "CURLOPT_CERTINFO";
    "CURLOPT_CLOSEPOLICY";
    "CURLOPT_CONNECTTIMEOUT";
    "CURLOPT_CONNECTTIMEOUT_MS";
    "CURLOPT_CONNECT_ONLY";
    "CURLOPT_CONNECT_TO";
    "CURLOPT_COOKIE";
    "CURLOPT_COOKIEFILE";
    "CURLOPT_COOKIEJAR";
    "CURLOPT_COOKIELIST";
    "CURLOPT_COOKIESESSION";
    "CURLOPT_COPYPOSTFIELDS";
    "CURLOPT_CRLF";
    "CURLOPT_CUSTOMREQUEST";
    "CURLOPT_DEBUGDATA";
    "CURLOPT_DEBUGFUNCTION";
    "CURLOPT_DNS_CACHE_TIMEOUT";
    "CURLOPT_DNS_SERVERS";
    "CURLOPT_DNS_USE_GLOBAL_CACHE";
    "CURLOPT_EGDSOCKET";
    "CURLOPT_ENCODING";
    "CURLOPT_ERRORBUFFER";
    "CURLOPT_FAILONERROR";
    "CURLOPT_FILE";
    "CURLOPT_FILETIME";
    "CURLOPT_FOLLOWLOCATION";
    "CURLOPT_FORBID_REUSE";
    "CURLOPT_FRESH_CONNECT";
    "CURLOPT_FTPAPPEND";
    "CURLOPT_FTPLISTONLY";
    "CURLOPT_FTPPORT";
    "CURLOPT_FTPSSLAUTH";
    "CURLOPT_FTP_ACCOUNT";
    "CURLOPT_FTP_ALTERNATIVE_TO_USER";
    "CURLOPT_FTP_CREATE_MISSING_DIRS";
    "CURLOPT_FTP_FILEMETHOD";
    "CURLOPT_FTP_RESPONSE_TIMEOUT";
    "CURLOPT_FTP_SKIP_PASV_IP";
    "CURLOPT_FTP_SSL";
    "CURLOPT_FTP_SSL_CCC";
    "CURLOPT_FTP_USE_EPRT";
    "CURLOPT_FTP_USE_EPSV";
    "CURLOPT_HEADER";
    "CURLOPT_HEADERFUNCTION";
    "CURLOPT_HTTP200ALIASES";
    "CURLOPT_HTTPAUTH";
    "CURLOPT_HTTPGET";
    "CURLOPT_HTTPHEADER";
    "CURLOPT_HTTPPOST";
    "CURLOPT_HTTPPROXYTUNNEL";
    "CURLOPT_HTTP_CONTENT_DECODING";
    "CURLOPT_HTTP_TRANSFER_DECODING";
    "CURLOPT_HTTP_VERSION";
    "CURLOPT_IGNORE_CONTENT_LENGTH";
    "CURLOPT_INFILE";
    "CURLOPT_INFILESIZE";
    "CURLOPT_INFILESIZE_LARGE";
    "CURLOPT_INTERFACE";
    "CURLOPT_IOCTLFUNCTION";
    "CURLOPT_IPRESOLVE";
    "CURLOPT_KRB4LEVEL";
    "CURLOPT_LOCALPORT";
    "CURLOPT_LOCALPORTRANGE";
    "CURLOPT_LOGIN_OPTIONS";
    "CURLOPT_LOW_SPEED_LIMIT";
    "CURLOPT_LOW_SPEED_TIME";
    "CURLOPT_MAIL_FROM";
    "CURLOPT_MAIL_RCPT";
    "CURLOPT_MAXCONNECTS";
    "CURLOPT_MAXFILESIZE";
    "CURLOPT_MAXFILESIZE_LARGE";
    "CURLOPT_MAXREDIRS";
    "CURLOPT_MAX_RECV_SPEED_LARGE";
    "CURLOPT_MAX_SEND_SPEED_LARGE";
    "CURLOPT_MIMEPOST";
    "CURLOPT_NETRC";
    "CURLOPT_NETRC_FILE";
    "CURLOPT_NEW_DIRECTORY_PERMS";
    "CURLOPT_NEW_FILE_PERMS";
    "CURLOPT_NOBODY";
    "CURLOPT_NOPROGRESS";
    "CURLOPT_NOSIGNAL";
    "CURLOPT_OPENSOCKETFUNCTION";
    "CURLOPT_PASSWORD";
    "CURLOPT_PIPEWAIT";
    "CURLOPT_PORT";
    "CURLOPT_POST";
    "CURLOPT_POST301";
    "CURLOPT_POSTFIELDS";
    "CURLOPT_POSTFIELDSIZE";
    "CURLOPT_POSTFIELDSIZE_LARGE";
    "CURLOPT_POSTQUOTE";
    "CURLOPT_POSTREDIR";
    "CURLOPT_PREQUOTE";
    "CURLOPT_PROGRESSDATA";
    "CURLOPT_PROGRESSFUNCTION";
    "CURLOPT_PROTOCOLS";
    "CURLOPT_PROXY";
    "CURLOPT_PROXYAUTH";
    "CURLOPT_PROXYPORT";
    "CURLOPT_PROXYTYPE";
    "CURLOPT_PROXYUSERPWD";
    "CURLOPT_PROXY_TRANSFER_MODE";
    "CURLOPT_PUT";
    "CURLOPT_QUOTE";
    "CURLOPT_RANDOM_FILE";
    "CURLOPT_RANGE";
    "CURLOPT_READFUNCTION";
    "CURLOPT_REDIR_PROTOCOLS";
    "CURLOPT_REFERER";
    "CURLOPT_RESOLVE";
    "CURLOPT_RESUME_FROM";
    "CURLOPT_RESUME_FROM_LARGE";
    "CURLOPT_SEEKFUNCTION";
    "CURLOPT_SHARE";
    "CURLOPT_SSH_AUTH_TYPES";
    "CURLOPT_SSH_HOST_PUBLIC_KEY_MD5";
    "CURLOPT_SSH_PRIVATE_KEYFILE";
    "CURLOPT_SSH_PUBLIC_KEYFILE";
    "CURLOPT_SSLCERT";
    "CURLOPT_SSLCERTPASSWD";
    "CURLOPT_SSLCERTTYPE";
    "CURLOPT_SSLENGINE";
    "CURLOPT_SSLENGINE_DEFAULT";
    "CURLOPT_SSLKEY";
    "CURLOPT_SSLKEYPASSWD";
    "CURLOPT_SSLKEYTYPE";
    "CURLOPT_SSLVERSION";
    "CURLOPT_SSL_CIPHER_LIST";
    "CURLOPT_SSL_SESSIONID_CACHE";
    "CURLOPT_SSL_VERIFYHOST";
    "CURLOPT_SSL_VERIFYPEER";
    "CURLOPT_TCP_NODELAY";
    "CURLOPT_TELNETOPTIONS";
    "CURLOPT_TIMECONDITION";
    "CURLOPT_TIMEOUT";
    "CURLOPT_TIMEOUT_MS";
    "CURLOPT_TIMEVALUE";
    "CURLOPT_TRANSFERTEXT";
    "CURLOPT_UNRESTRICTED_AUTH";
    "CURLOPT_UPLOAD";
    "CURLOPT_URL";
    "CURLOPT_USERAGENT";
    "CURLOPT_USERNAME";
    "CURLOPT_USERPWD";
    "CURLOPT_VERBOSE";
    "CURLOPT_WRITEFUNCTION";
    "CURLOPT_WRITEHEADER";
    "CURLOPT_WRITEINFO";
    "CURL_HTTP_VERSION_2";
    "CURL_HTTP_VERSION_2TLS";
    "CURL_HTTP_VERSION_2_0";
    "CURL_HTTP_VERSION_2_PRIOR_KNOWLEDGE";
    "CURL_HTTP_VERSION_3";
    "CURL_SSLVERSION_TLSv1_0";
    "CURL_SSLVERSION_TLSv1_1";
    "CURL_SSLVERSION_TLSv1_2";
    "CURL_SSLVERSION_TLSv1_3";
    "CURL_VERSION_NTLM_WB";
    "CURL_VERSION_TLSAUTH_SRP";
  ]

let headers =
  [
    "curl/curl.h";
    "inttypes.h";
    "memory.h";
    "stdint.h";
    "stdlib.h";
    "strings.h";
    "string.h";
    "sys/stat.h";
    "sys/types.h";
    "unistd.h";
  ]

let value_of_bool b = match b with true -> Value.Int 1 | false -> Value.Int 0

let generate_config_h t =
  let c_flags = c_flags t @ [ "-c" ] in
  let test_declaration str =
    let prog =
      Printf.sprintf
        {|
      #include <curl/curl.h>

      int main(void) {
        (void)%s;
      }
    |}
        str
    in
    let exists = c_test t ~c_flags prog in
    let value = value_of_bool exists in
    let definition = "HAVE_DECL_" ^ String.uppercase_ascii str in
    (definition, value)
  in

  let test_header str =
    let prog =
      Printf.sprintf {|
      #include <%s>

      int main(void) {}
    |} str
    in
    let compiles = c_test t ~c_flags prog in
    let value = value_of_bool compiles in
    let definition =
      "HAVE_"
      ^ (str
        |> Str.global_replace (Str.regexp_string "/") "_"
        |> Str.global_replace (Str.regexp_string ".") "_"
        |> String.uppercase_ascii)
    in
    (definition, value)
  in

  let decls = List.map test_declaration declarations in
  let hdrs = List.map test_header headers in

  gen_header_file ~fname:"config.h" t (decls @ hdrs)

let _ =
  main ~name:"curl" (fun t ->
      let os = get_os t in
      let flags = flags os in
      let c_flags = c_flags t in
      write_sexp "flags.sexp" flags;
      write_sexp "c_flags.sexp" c_flags;
      generate_config_h t)
