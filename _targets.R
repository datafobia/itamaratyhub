# Pipeline do espelhamento defensivo.
#
# Fase 0: construir o MANIFESTO, não baixar bytes.
#
# Rodar:  targets::tar_make()
# Ver:    targets::tar_read(resumo)

library(targets)

tar_option_set(
  packages = c("httr2", "rvest"),
  format   = "rds"
)

tar_source("R")

list(

  # ---- enumeração ---------------------------------------------------------

  tar_target(
    resenha_principal,
    marcar_duplicata_provavel(listar_apache(FONTES_APACHE$resenha$url)),
    cue = tar_cue(mode = "always")      # a listagem muda; sempre reconsultar
  ),

  tar_target(
    resenha_novas,
    marcar_duplicata_provavel(listar_apache(FONTES_APACHE$resenha_novas$url)),
    cue = tar_cue(mode = "always")
  ),

  tar_target(
    presidencia_cdx,
    {
      f <- FONTES_CDX$presidencia_discursos
      bruto <- cdx_consultar(f$dominio, match_type = f$match_type)
      bruto[grepl(f$filtro_caminho, bruto$original, fixed = TRUE), , drop = FALSE]
    }
  ),

  # ---- sondagem e manifesto ----------------------------------------------

  tar_target(
    manifesto_resenha,
    manifesto_direto(rbind(resenha_principal, resenha_novas), "resenha")
  ),

  tar_target(
    manifesto_presidencia,
    manifesto_wayback(presidencia_cdx, "presidencia")
  ),

  tar_target(
    manifesto,
    {
      partes <- Filter(Negate(is.null),
                       list(manifesto_resenha, manifesto_presidencia))
      colunas <- Reduce(intersect, lapply(partes, names))
      do.call(rbind, lapply(partes, function(p) p[, colunas, drop = FALSE]))
    }
  ),

  # ---- saídas -------------------------------------------------------------

  tar_target(
    manifesto_csv,
    {
      caminho <- "manifesto/manifesto.csv"
      utils::write.csv(manifesto, caminho, row.names = FALSE, fileEncoding = "UTF-8")
      caminho
    },
    format = "file"
  ),

  tar_target(resumo, resumir_manifesto(manifesto))
)
