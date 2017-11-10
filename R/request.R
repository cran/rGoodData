#' Processes http response and returns a list of results
#' @keywords internal
#'
#' @param response http response from the GoodData API
#' @return list of resutls parsed from the response
processResponse <- function(response) {
  status <- status_code(response)
  if(status >= 200 & status < 300) {
    c <- content(response, "parsed", http_type(response))
  } else { # error
    processResponseError(response)
  }
}

#' Stops the execution for response with bad status codes
#' @keywords internal
#'
#' @param response HTTP response that has error status code
processResponseError <- function(response) {
  type <- http_type(response)
  if (type == "application/json") {
    out <- content(response, "parsed", "application/json")
    if("error" %in% names(out)) {
      stop("HTTP error [", out$error$code, "] ", out$error$message, call. = FALSE)
    }
    stop("HTTP error [", status_code(response), "] ", out$message, call. = FALSE)
  } else {
    out <- content(response, "text")
    stop("HTTP error [", status_code(response), "] ", out, call. = FALSE)
  }
}

#' Helper function that gets user agent header
getUserAgent <- function() {
  user.agent <- Sys.getenv("GOODDATA_USER_AGENT",
                           unset = paste0("rGoodData" , " / ", packageVersion("rGoodData")))
  return(user.agent)
}
