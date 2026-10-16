# Enumeração de diretórios Apache abertos (acervos da FUNAG).
#
# Verificado em 2026-10-16:
#   .../Resenhas/        -> 76 PDFs
#   .../Resenhas/Novas/  -> 64 PDFs
#
# Atenção: a nomenclatura é inconsistente (`dec`/`dez`, `1sem`/`1Sem`,
# `Resenha`/`resenha`/`RESENHA`) e há duplicatas marcadas com "(1)".
# Por isso enumeramos a listagem em vez de gerar URLs por fórmula.

#' Lista os arquivos de uma listagem de diretório Apache
#'
#' @param url_dir URL do diretório, com barra final
#' @param ext extensão a reter, sem ponto
#' @return data.frame com url, arquivo e diretorio
listar_apache <- function(url_dir, ext = "pdf") {
  peb_log("listando ", url_dir)
  corpo <- peb_req(url_dir) |>
    httr2::req_perform() |>
    httr2::resp_body_string()

  hrefs <- rvest::read_html(corpo) |>
    rvest::html_elements("a") |>
    rvest::html_attr("href")

  hrefs <- hrefs[!is.na(hrefs)]
  # Descarta os links de ordenação do Apache (?C=N;O=D) e o link para o pai
  hrefs <- hrefs[!startsWith(hrefs, "?")]
  hrefs <- hrefs[!startsWith(hrefs, "/")]
  hrefs <- hrefs[grepl(paste0("\\.", ext, "$"), hrefs, ignore.case = TRUE)]
  hrefs <- unique(hrefs)

  if (length(hrefs) == 0) {
    stop("nenhum .", ext, " encontrado em ", url_dir,
         " - a listagem provavelmente mudou de formato")
  }

  base <- sub("/$", "", url_dir)
  data.frame(
    url       = paste0(base, "/", hrefs),
    arquivo   = vapply(hrefs, utils::URLdecode, character(1), USE.NAMES = FALSE),
    diretorio = url_dir,
    stringsAsFactors = FALSE
  )
}

#' Marca prováveis duplicatas geradas pelo servidor: "nome (1).pdf"
#'
#' Não remove nada. A decisão de descartar depende de comparar o SHA-256,
#' o que só é possível depois do download.
marcar_duplicata_provavel <- function(df) {
  df$duplicata_provavel <- grepl("\\(\\d+\\)\\.[A-Za-z]+$", df$arquivo)
  df
}
