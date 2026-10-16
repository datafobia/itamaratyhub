# Registro de fontes.
#
# Regra do repositório: só entra aqui URL que foi verificada ao vivo, com a
# data da verificação. Fonte não verificada fica em FONTES_PENDENTES, sem URL
# inventada, até que alguém faça o reconhecimento.

# ---------------------------------------------------------------- ativas ----

FONTES_APACHE <- list(
  resenha = list(
    acervo = "resenha",
    descricao = "Resenha de Politica Exterior do Brasil (diretorio principal)",
    url = "https://funag.gov.br/chdd/images/Resenhas/",
    verificado_em = "2026-10-16",
    esperado = 76
  ),
  resenha_novas = list(
    acervo = "resenha",
    descricao = "Resenha de Politica Exterior do Brasil (edicoes recentes)",
    url = "https://funag.gov.br/chdd/images/Resenhas/Novas/",
    verificado_em = "2026-10-16",
    esperado = 64
  )
)

FONTES_CDX <- list(
  presidencia_discursos = list(
    acervo = "presidencia",
    descricao = paste("Biblioteca da Presidencia da Republica, discursos.",
                      "Fonte primaria fora do ar desde ~set/2026."),
    dominio = "biblioteca.presidencia.gov.br",
    match_type = "domain",
    filtro_caminho = "/discursos/",
    verificado_em = "2026-10-16",
    # Medido com teto de 60.000 na consulta exploratoria; o total e maior.
    esperado_minimo = 10310
  ),
  mre_notas = list(
    acervo = "mre_notas",
    descricao = paste("Notas a imprensa do MRE.",
                      "Arquivo purgado do site vivo; so sobrevive no Wayback."),
    dominio = "gov.br/mre",
    match_type = "prefix",
    filtro_caminho = "nota",
    verificado_em = NA_character_,   # enumeracao ainda nao conferida a mao
    esperado_minimo = NA_integer_
  )
)

# ------------------------------------------------------------- pendentes ----
# Precisam de reconhecimento manual antes de virar coleta. Deliberadamente
# sem URL: o relatorio de origem cita volumes, mas nao confirmei os caminhos.

FONTES_PENDENTES <- data.frame(
  acervo = c("anuarios_mre", "relatorios_mre", "funag_livros", "senado_msf"),
  descricao = c(
    "Anuarios/Almanaques do Pessoal do MRE, 1916-2010 (~52 PDFs, ~4,85 GB, com camada OCR)",
    "Relatorios do MRE, 1830-1960 (~7,3 GB, sem camada de texto)",
    "Biblioteca Digital da FUNAG (~1.097 titulos, IDs sequenciais)",
    "Sabatinas de embaixadores (MSF), Senado, 1988-hoje; endpoint em desativacao"
  ),
  bloqueio = c(
    "indice atras de require_login; localizar host legado",
    "idem; confirmar se ha camada de texto em algum volume",
    "confirmar faixa de IDs e padrao de URL",
    "confirmar se /processo substitui /materia para MSF"
  ),
  stringsAsFactors = FALSE
)
