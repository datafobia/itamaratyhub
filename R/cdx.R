# Enumeração via Wayback CDX Server API.
#
# Usada para os acervos que já saíram do ar ou foram purgados:
#   - biblioteca.presidencia.gov.br  (fora do ar desde ~set/2026)
#   - gov.br/mre .../notas-a-imprensa (arquivo purgado)
#
# NOTA DE CORREÇÃO (2026-10-16): o host é `biblioteca.presidencia.gov.br`,
# no SINGULAR. A grafia `bibliotecas...` não tem nenhuma captura no CDX.
#
# O CDX já devolve statuscode e length por captura, então os acervos vindos
# daqui NÃO precisam de sondagem HEAD — o que economiza horas de requisição.

CDX_ENDPOINT <- "http://web.archive.org/cdx/search/cdx"

#' Consulta o CDX paginando por resumeKey
#'
#' @param dominio host ou prefixo
#' @param match_type "domain", "prefix", "host" ou "exact"
#' @param por_pagina tamanho de cada página
#' @param max_paginas trava de segurança
#' @return data.frame com original, timestamp, statuscode, mimetype, length
cdx_consultar <- function(dominio,
                          match_type  = "domain",
                          por_pagina  = 50000,
                          max_paginas = 40) {
  campos <- c("original", "timestamp", "statuscode", "mimetype", "length")
  acumulado <- list()
  resume <- NULL

  for (pagina in seq_len(max_paginas)) {
    req <- peb_req(CDX_ENDPOINT, timeout = 300) |>
      httr2::req_url_query(
        url            = dominio,
        matchType      = match_type,
        collapse       = "urlkey",
        fl             = paste(campos, collapse = ","),
        filter         = "statuscode:200",
        limit          = por_pagina,
        showResumeKey  = "true"
      )
    if (!is.null(resume)) req <- httr2::req_url_query(req, resumeKey = resume)

    txt <- req |> httr2::req_perform() |> httr2::resp_body_string()
    linhas <- strsplit(txt, "\n", fixed = TRUE)[[1]]
    linhas <- trimws(linhas)

    # O resumeKey vem após uma linha em branco, no fim da resposta
    vazias <- which(linhas == "")
    resume_novo <- NULL
    if (length(vazias) > 0) {
      ultima <- max(vazias)
      if (ultima < length(linhas)) resume_novo <- linhas[ultima + 1]
      linhas <- linhas[seq_len(ultima - 1)]
    }
    linhas <- linhas[linhas != ""]

    if (length(linhas) > 0) {
      partes <- strsplit(linhas, " ", fixed = TRUE)
      partes <- partes[lengths(partes) == length(campos)]
      if (length(partes) > 0) {
        m <- do.call(rbind, partes)
        df <- as.data.frame(m, stringsAsFactors = FALSE)
        names(df) <- campos
        acumulado[[length(acumulado) + 1]] <- df
      }
    }

    peb_log("cdx ", dominio, " pagina ", pagina, ": ", length(linhas), " linhas")
    if (is.null(resume_novo) || resume_novo == "") break
    resume <- resume_novo
  }

  if (length(acumulado) == 0) {
    return(data.frame(original = character(), timestamp = character(),
                      statuscode = character(), mimetype = character(),
                      length = character(), stringsAsFactors = FALSE))
  }

  out <- do.call(rbind, acumulado)
  out$length <- sanear_length(suppressWarnings(as.numeric(out$length)))
  out[!duplicated(out$original), , drop = FALSE]
}

#' Sanea o campo `length` do CDX
#'
#' Medido em 2026-10-16: 8 de 10.130 registros de
#' biblioteca.presidencia.gov.br vêm com valores impossíveis (até
#' -10.485.042.932). Sem tratamento, oito linhas corrompidas invertem o sinal
#' do total do acervo inteiro.
#'
#' ATENÇÃO SEMÂNTICA: `length` no CDX é o tamanho do REGISTRO WARC comprimido,
#' não o tamanho do recurso original. Para linhas vindas do Wayback, a coluna
#' `bytes` do manifesto é uma aproximação por baixo, e está marcada como tal
#' na coluna `bytes_medida`.
sanear_length <- function(x) {
  implausivel <- is.na(x) | x <= 0 | x > 2^31
  x[implausivel] <- NA_real_
  x
}

#' URL para recuperar a captura original (sem a moldura do Wayback)
#'
#' O sufixo "id_" devolve o recurso tal como foi arquivado.
cdx_url_captura <- function(timestamp, original) {
  paste0("http://web.archive.org/web/", timestamp, "id_/", original)
}
