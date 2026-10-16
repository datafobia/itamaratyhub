# Download dos arquivos, com verificação de integridade.
#
# Projetado para rodar em GitHub Actions, não no notebook: o runner tem 14 GB
# de disco e nenhuma persistência entre jobs. O padrão é baixar um lote,
# enviar para a Release e morrer.
#
# Por isso toda função aqui opera sobre LOTES, nunca sobre o acervo inteiro.

#' Baixa uma URL e devolve o registro de integridade
#'
#' Nunca lança erro: falha vira linha com estado, porque um lote parcial é
#' resultado útil e um job que aborta no arquivo 300 de 400 não é.
baixar_url <- function(url, destino) {
  inicio <- Sys.time()
  reg <- tryCatch({
    peb_req(url, timeout = 600) |>
      httr2::req_progress() |>
      httr2::req_perform(path = destino)

    list(ok = TRUE,
         bytes = file.size(destino),
         sha256 = paste(openssl::sha256(file(destino, "rb")), collapse = ""),
         erro = NA_character_)
  }, error = function(e) {
    if (file.exists(destino)) unlink(destino)
    list(ok = FALSE, bytes = NA_real_, sha256 = NA_character_,
         erro = conditionMessage(e))
  })

  data.frame(
    url        = url,
    destino    = destino,
    ok         = reg$ok,
    bytes      = reg$bytes,
    sha256     = reg$sha256,
    erro       = reg$erro,
    segundos   = round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 1),
    baixado_em = peb_agora(),
    stringsAsFactors = FALSE
  )
}

#' Nome de arquivo seguro: ASCII, sem acento, sem espaço
#'
#' No Windows, caminhos com acento combinados com `targets` já causaram
#' problema. O nome original fica preservado no manifesto como metadado.
nome_seguro <- function(x) {
  # A URL traz percent-encoding ("%C3%B3", "%20"); sem decodificar antes,
  # "Relatorio 1961.pdf" vira "Relat_C3_B3rio_201961.pdf" e o ano fica ilegivel.
  x <- vapply(x, utils::URLdecode, character(1), USE.NAMES = FALSE)
  y <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT", sub = "")
  y <- gsub("[^A-Za-z0-9._-]+", "_", y)
  y <- gsub("_+", "_", y)
  sub("^_", "", y)
}

#' Baixa um lote e grava o registro de integridade ao lado
#'
#' @param manifesto linhas do manifesto a baixar
#' @param pasta diretório de saída
#' @param pular_existentes não rebaixar o que já está em disco com o tamanho certo
baixar_lote <- function(manifesto, pasta, pular_existentes = TRUE) {
  dir.create(pasta, recursive = TRUE, showWarnings = FALSE)
  peb_log("baixando lote de ", nrow(manifesto), " arquivos para ", pasta)

  linhas <- vector("list", nrow(manifesto))
  for (i in seq_len(nrow(manifesto))) {
    destino <- file.path(pasta, nome_seguro(manifesto$arquivo[i]))

    if (pular_existentes && file.exists(destino) &&
        isTRUE(file.size(destino) == manifesto$bytes[i])) {
      linhas[[i]] <- data.frame(
        url = manifesto$url[i], destino = destino, ok = TRUE,
        bytes = file.size(destino),
        sha256 = paste(openssl::sha256(file(destino, "rb")), collapse = ""),
        erro = NA_character_, segundos = 0, baixado_em = peb_agora(),
        stringsAsFactors = FALSE
      )
      next
    }

    linhas[[i]] <- baixar_url(manifesto$url[i], destino)
    peb_log("  ", i, "/", nrow(manifesto), " ", basename(destino),
            if (linhas[[i]]$ok) "" else " FALHOU")
  }

  do.call(rbind, linhas)
}

#' Divide o manifesto em lotes de tamanho máximo em GB
#'
#' O runner do Actions tem 14 GB de disco. Lotes de 4 GB deixam folga para
#' o sistema, o R e o upload.
lotear <- function(manifesto, gb_por_lote = 4) {
  bytes <- manifesto$bytes
  bytes[is.na(bytes)] <- 0
  limite <- gb_por_lote * 1024^3

  lote <- integer(nrow(manifesto))
  atual <- 1L
  acumulado <- 0
  for (i in seq_len(nrow(manifesto))) {
    if (acumulado + bytes[i] > limite && acumulado > 0) {
      atual <- atual + 1L
      acumulado <- 0
    }
    lote[i] <- atual
    acumulado <- acumulado + bytes[i]
  }
  manifesto$lote <- lote
  manifesto
}
