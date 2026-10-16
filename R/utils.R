# Infraestrutura comum de coleta.
#
# Princípio: toda requisição sai identificada, limitada a 1 req/s por host e
# com retentativa exponencial. Isso é o que torna a coleta defensável perante
# quem hospeda os acervos.

PEB_UA <- paste0(
  "peb-mirror/0.1 (espelhamento academico de acervos publicos; ",
  "UFPE; dalson.figueiredofo@ufpe.br)"
)

#' Host de uma URL, usado como "realm" do limitador de taxa
peb_host <- function(url) {
  h <- httr2::url_parse(url)$hostname
  if (is.null(h) || is.na(h)) "desconhecido" else h
}

#' Requisição-base: identificada, educada e resiliente
#'
#' O throttle é por host, de modo que coletar da FUNAG não atrase a coleta
#' do Wayback e vice-versa.
peb_req <- function(url, timeout = 60) {
  httr2::request(url) |>
    httr2::req_user_agent(PEB_UA) |>
    httr2::req_throttle(capacity = 1, fill_time_s = 1, realm = peb_host(url)) |>
    httr2::req_retry(max_tries = 4, backoff = function(i) 2^i) |>
    httr2::req_timeout(timeout)
}

#' Mensagem de progresso com horário, para logs longos de CI
peb_log <- function(...) {
  message(format(Sys.time(), "[%H:%M:%S] "), ...)
}

#' Data/hora de captura em UTC, no formato que vai para o manifesto
peb_agora <- function() format(as.POSIXct(Sys.time(), tz = "UTC"), "%Y-%m-%dT%H:%M:%SZ")
