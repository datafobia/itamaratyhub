# Construção do manifesto.
#
# O manifesto é o artefato durável deste repositório: uma linha por arquivo,
# com origem, tamanho, estado e data de verificação. Ele é versionado em Git
# (é pequeno) enquanto os bytes vão para a Release (são grandes).
#
# Rodado semanalmente, o manifesto vira também um registro longitudinal de
# mortalidade de fontes públicas: o que estava no ar e deixou de estar.

#' Sonda uma URL com HEAD, sem baixar o corpo
#'
#' Nunca lança erro: falha vira uma linha com estado "erro", porque uma
#' fonte morta é um dado do manifesto, não uma exceção do pipeline.
sondar_url <- function(url) {
  resultado <- tryCatch({
    resp <- peb_req(url, timeout = 45) |>
      httr2::req_method("HEAD") |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform()

    list(
      status       = httr2::resp_status(resp),
      bytes        = suppressWarnings(as.numeric(
                       httr2::resp_header(resp, "content-length"))),
      tipo         = httr2::resp_header(resp, "content-type"),
      modificado   = httr2::resp_header(resp, "last-modified"),
      url_final    = resp$url,
      erro         = NA_character_
    )
  }, error = function(e) {
    list(status = NA_integer_, bytes = NA_real_, tipo = NA_character_,
         modificado = NA_character_, url_final = NA_character_,
         erro = conditionMessage(e))
  })

  data.frame(
    url             = url,
    status          = resultado$status  %||% NA_integer_,
    bytes           = resultado$bytes   %||% NA_real_,
    tipo_conteudo   = resultado$tipo    %||% NA_character_,
    modificado_em   = resultado$modificado %||% NA_character_,
    url_final       = resultado$url_final  %||% NA_character_,
    erro            = resultado$erro,
    verificado_em   = peb_agora(),
    stringsAsFactors = FALSE
  )
}

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

#' Sonda um vetor de URLs, com log de progresso
sondar_lote <- function(urls, rotulo = "") {
  peb_log("sondando ", length(urls), " URLs ", rotulo)
  linhas <- vector("list", length(urls))
  for (i in seq_along(urls)) {
    linhas[[i]] <- sondar_url(urls[i])
    if (i %% 25 == 0) peb_log("  ", i, "/", length(urls))
  }
  do.call(rbind, linhas)
}

#' Monta o manifesto de um acervo baixável diretamente (FUNAG)
manifesto_direto <- function(arquivos, acervo) {
  sondas <- sondar_lote(arquivos$url, rotulo = paste0("(", acervo, ")"))
  out <- merge(arquivos, sondas, by = "url", all.x = TRUE)
  out$acervo <- acervo
  out$fonte  <- "direta"
  # Aqui o tamanho vem do Content-Length do próprio servidor: é o recurso real.
  out$bytes_medida <- "content_length"
  out
}

#' Monta o manifesto de um acervo vindo do Wayback
#'
#' Aqui não há sondagem: o próprio CDX informa status e tamanho.
manifesto_wayback <- function(cdx, acervo) {
  if (nrow(cdx) == 0) return(NULL)
  data.frame(
    url             = cdx_url_captura(cdx$timestamp, cdx$original),
    arquivo         = basename(sub("\\?.*$", "", cdx$original)),
    diretorio       = NA_character_,
    duplicata_provavel = FALSE,
    status          = suppressWarnings(as.integer(cdx$statuscode)),
    bytes           = cdx$length,
    tipo_conteudo   = cdx$mimetype,
    modificado_em   = NA_character_,
    url_final       = cdx$original,
    erro            = NA_character_,
    verificado_em   = peb_agora(),
    acervo          = acervo,
    fonte           = "wayback",
    # O CDX informa o tamanho do registro WARC comprimido, não o do recurso.
    bytes_medida    = "warc_comprimido",
    stringsAsFactors = FALSE
  )
}

#' Resumo legível do manifesto, impresso no log do CI
#'
#' Reporta separadamente o que foi medido e o que ficou sem medida, porque um
#' total que esconde quantas linhas entraram como NA é um total que mente.
resumir_manifesto <- function(m) {
  partes <- split(m, m$acervo)
  linhas <- lapply(names(partes), function(nome) {
    p <- partes[[nome]]
    b <- p$bytes
    data.frame(
      acervo       = nome,
      arquivos     = nrow(p),
      com_tamanho  = sum(!is.na(b)),
      sem_tamanho  = sum(is.na(b)),
      GB           = round(sum(b, na.rm = TRUE) / 1024^3, 2),
      medida       = paste(unique(p$bytes_medida), collapse = "/"),
      vivos_200    = sum(!is.na(p$status) & p$status == 200),
      mortos_4xx5xx = sum(!is.na(p$status) & p$status >= 400),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, linhas)
}
