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
    anuarios_lista,
    marcar_duplicata_provavel(listar_apache(FONTES_APACHE$anuarios$url)),
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

  tar_target(
    relatorios_cdx,
    {
      f <- FONTES_CDX$relatorios_mre
      bruto <- cdx_consultar(f$dominio, match_type = f$match_type)
      # O indice do Wayback contem URLs corrompidas por hifenizacao do HTML
      # arquivado ("ima-ges/", "Re-latorios/"). Nao sao caminhos reais.
      bruto <- bruto[!grepl("-(ges|latorios)/", bruto$original), , drop = FALSE]
      bruto[grepl(f$filtro_caminho, bruto$original, fixed = TRUE) &
              grepl("\\.pdf$", bruto$original, ignore.case = TRUE), , drop = FALSE]
    }
  ),

  # ---- sondagem e manifesto ----------------------------------------------

  tar_target(
    manifesto_resenha,
    manifesto_direto(rbind(resenha_principal, resenha_novas), "resenha")
  ),

  tar_target(
    manifesto_anuarios,
    manifesto_direto(anuarios_lista, "anuarios")
  ),

  tar_target(
    manifesto_presidencia,
    manifesto_wayback(presidencia_cdx, "presidencia")
  ),

  tar_target(
    manifesto_relatorios,
    manifesto_wayback(relatorios_cdx, "relatorios")
  ),

  tar_target(
    manifesto,
    {
      partes <- Filter(Negate(is.null),
                       list(manifesto_resenha, manifesto_anuarios,
                            manifesto_presidencia, manifesto_relatorios))
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
