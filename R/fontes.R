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
  ),
  anuarios = list(
    acervo = "anuarios",
    descricao = paste("Anuarios do Pessoal do MRE, 1916-2010.",
                      "Curriculo funcional de cada diplomata; ja tem camada OCR.",
                      "Base do projeto de prosopografia do corpo diplomatico."),
    url = "https://funag.gov.br/chdd/images/Anuario_Funcionarios_MRE/",
    verificado_em = "2026-10-16",
    esperado = 52
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
  relatorios_mre = list(
    acervo = "relatorios",
    descricao = paste("Relatorios do MRE, 1830-1960.",
                      "Sem camada de texto: OCR do zero, com ortografia",
                      "anterior a reforma de 1943. Fase 3, nao fase 0."),
    # A listagem viva deste diretorio esta DESABILITADA: devolve 200 com 47
    # bytes e nenhum link, ao contrario de /Resenhas/ e /Anuario_Funcionarios_MRE/.
    # Os arquivos existem (ex.: Relatorio_1863A.PDF) e so sao enumeraveis
    # pelo indice do Wayback.
    dominio = "funag.gov.br/chdd/images/Relatorios",
    match_type = "prefix",
    filtro_caminho = "/Relatorios/",
    verificado_em = "2026-10-16",
    esperado_minimo = NA_integer_
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
  acervo = c("funag_livros", "senado_msf", "mre_discursos"),
  descricao = c(
    "Biblioteca Digital da FUNAG (~1.097 titulos, IDs sequenciais)",
    "Sabatinas de embaixadores (MSF), Senado, 1988-hoje; endpoint em desativacao",
    "Discursos de chanceleres e do SG em gov.br/mre"
  ),
  bloqueio = c(
    "confirmar faixa de IDs e padrao de URL",
    "confirmar se /processo substitui /materia para MSF",
    "gov.br devolveu 'Conteudo Restrito' a acesso profundo; exige reconhecimento manual"
  ),
  stringsAsFactors = FALSE
)

# Resolvidos em 2026-10-16, saindo desta lista:
#   anuarios   -> listagem Apache aberta, 52 PDFs confirmados
#   relatorios -> listagem desabilitada, mas enumeravel pelo Wayback
