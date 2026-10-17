# Proveniência, método e situação jurídica

## Princípio

Toda linha do manifesto registra: URL de origem, data e hora da verificação em
UTC, status HTTP, tamanho em bytes e, quando o arquivo é baixado, o SHA-256.
Nada entra no registro de fontes sem verificação ao vivo, com data.

## O que foi verificado, e quando

Verificação de 2026-10-16, feita com requisições reais:

| Fonte | Resultado |
|---|---|
| `funag.gov.br/chdd/images/Resenhas/` | HTTP 200, **76 PDFs** na listagem Apache |
| `funag.gov.br/chdd/images/Resenhas/Novas/` | HTTP 200, **64 PDFs** |
| `funag.gov.br/chdd/images/Anuario_Funcionarios_MRE/` | HTTP 200, **52 PDFs** na listagem Apache — confirma a contagem estimada |
| `funag.gov.br/chdd/images/Relatorios/` | HTTP 200, mas a listagem está **desabilitada**: 47 bytes, nenhum link. Os arquivos existem e só são enumeráveis pelo Wayback |
| Wayback CDX, `biblioteca.presidencia.gov.br` | ativo; **mais de 60.000 URLs únicas**, das quais **ao menos 10.310** sob `/discursos/` |
| Wayback CDX, `bibliotecas.presidencia.gov.br` | **zero capturas** |

## Primeiro manifesto — medido, não estimado

Execução de 2026-10-16, `targets::tar_make()`:

| Acervo | Arquivos | Vivos (200) | Mortos (4xx/5xx) | Tamanho | Medida |
|---|---|---|---|---|---|
| `anuarios` | 52 | 52 | 0 | **4,74 GB** | `Content-Length` |
| `presidencia` | 10.130 | 10.130 | 0 | 0,98 GB | registro WARC comprimido |
| `relatorios` | 137 | 137 | 0 | 0,20 GB | registro WARC comprimido |
| `resenha` | 140 | 140 | 0 | **0,72 GB** | `Content-Length` |

Total: 10.459 arquivos, nenhum morto.

Observações que mudam o planejamento:

- **A Resenha tem 140 arquivos e 124 edições únicas — confirmado por hash.**
  Os 16 arquivos com sufixo `(1)` são cópias **byte a byte idênticas** do
  arquivo sem sufixo: 16 de 16, nenhum falso positivo, nenhum par divergente.
  A heuristica `marcar_duplicata_provavel()` acertou todos. Medido no download
  de 2026-10-16; registro em `manifesto/integridade_resenha.csv`.
- **Os Anuários confirmaram a estimativa: 4,74 GB medidos contra 4,85 GB
  estimados, e exatamente os 52 PDFs esperados.** É o único acervo grande em
  que estimativa e medição convergiram.
- **Os 0,20 GB de `relatorios` não são o peso do acervo.** Vêm do CDX, que
  informa o registro WARC comprimido. A estimativa independente aponta ~7,3 GB.
  Enquanto o download não acontecer, o peso real desse acervo é desconhecido —
  e é a maior incerteza de dimensionamento que resta.
- **Dos ~13 GB estimados, 6,4 GB estão medidos.** O que falta é quase todo
  `relatorios`, mais a Biblioteca Digital da FUNAG, que segue sem URL.
- Para `presidencia`, 8 de 10.130 registros vinham com `length` impossível
  (até −10.485.042.932) e agora entram como `NA`. Ver `sanear_length()`.
- Nenhuma URL morta em nenhum dos quatro acervos nesta execução. O valor do
  manifesto semanal é justamente detectar quando isso mudar.

### Três correções a relatórios anteriores

1. **O host da Biblioteca da Presidência é `biblioteca`, no singular.** A grafia
   no plural, que constava do levantamento inicial, não tem nenhuma captura no
   Wayback. O volume também é maior do que o estimado: mais de 60.000 URLs
   únicas contra 25.819, e ao menos 10.310 sob `/discursos/` contra 8.677.
   O número real é maior ainda — 60.000 foi o teto da consulta exploratória.

2. **O diretório `/Resenhas/Novas/` tem 64 PDFs, não 61.** Diferença pequena,
   mas ilustra a razão de enumerar a listagem em vez de confiar em contagem
   registrada: o acervo muda.

3. **A listagem de `/Relatorios/` está desabilitada, mas o acervo não está
   perdido.** O diretório devolve 200 com 47 bytes e nenhum link, ao contrário
   de `/Resenhas/` e `/Anuario_Funcionarios_MRE/`. O índice do Wayback o
   enumera — com a ressalva de que contém URLs corrompidas por hifenização do
   HTML arquivado (`ima-ges/`, `Re-latorios/`), que são filtradas por não
   corresponderem a caminho real.

## Primeiro download — `relatorios`, 2026-10-16

O primeiro acervo efetivamente baixado. Registro completo, com SHA-256 por
arquivo, em `manifesto/integridade_relatorios.csv`.

| | |
|---|---|
| arquivos | 137 de 137, nenhuma falha |
| tamanho real | **7,11 GB** |
| hashes distintos | 137 — **nenhuma duplicata** |
| maior / menor | 149,4 MB (`Relatorio_1914-1915.pdf`) / 2,5 MB |
| origem dos bytes | `funag.gov.br`, não o Wayback |
| integridade | SHA-256 recalculado sobre os 7,2 GB em disco: **137 de 137 conferem** |

Três coisas que este download corrigiu:

1. **O acervo vai de 1830 a 1988, não a 1960.** A faixa registrada até aqui
   subestimava em 28 anos. Medida sobre os nomes de arquivo, que trazem o ano
   em todos os 137 casos. Distribuição por década razoavelmente uniforme no
   século XIX (~10 por década) e magra nos anos 1900 (3 arquivos).
2. **Os arquivos nunca saíram do ar.** Os 137 respondem 200 na FUNAG, com
   `Content-Length`. O que está quebrado é só a listagem do diretório. O
   Wayback foi necessário para descobrir os nomes, não para recuperar os
   bytes — e isso enfraquece, para este acervo, o argumento de resgate
   defensivo: não é fonte em risco iminente, é fonte com índice quebrado.
3. **O manifesto subestimava o tamanho por um fator de 35** (0,20 GB de WARC
   comprimido contra 7,11 GB reais). Confirma, com medição, a ressalva que já
   estava registrada sobre a coluna `bytes_medida`.

Os bytes **não** estão neste repositório: `saida/` está no `.gitignore`. O que
é publicado aqui é o registro de integridade — que basta para qualquer pessoa
reconstruir e conferir o acervo a partir da origem.

## Downloads de `resenha` e `anuarios`, 2026-10-16

| | `resenha` | `anuarios` |
|---|---|---|
| arquivos | 140 | 52 |
| tamanho | 0,72 GB | 4,74 GB |
| hashes distintos | **124** (16 duplicatas idênticas) | **52** (nenhuma duplicata) |
| faixa | 1974–2019 | 1916–2010 |
| falhas na coleta | 0 | 0 |
| SHA-256 conferidos na Release | 140 de 140 | 52 de 52 |

Registros em `manifesto/integridade_resenha.csv` e
`manifesto/integridade_anuarios.csv`.

### Sobre a licença — correção de leitura

Este documento tratava a CC BY-ND 3.0 da FUNAG como impedimento ao
espelhamento. **Era leitura equivocada.** A cláusula *NoDerivatives* veda
distribuir material **modificado**; copiar e redistribuir a obra íntegra, com
atribuição, é expressamente permitido pela licença.

Logo, as Releases de `resenha` e `anuarios` cumprem o BY-ND: redistribuem os
arquivos sem qualquer alteração, com atribuição à FUNAG/MRE, e publicam os
SHA-256 ao lado como prova verificável de integridade.

O que o ND **de fato** restringe é a fase seguinte: OCR, corpus, texto
derivado. Essa questão continua em aberto e é a que exige resposta da FUNAG ou
parecer jurídico — não o espelhamento.

## Fontes ainda não verificadas

Listadas em `R/fontes.R`, em `FONTES_PENDENTES`, **sem URL**. Elas aparecem em
levantamentos com volumes estimados, mas os caminhos não foram confirmados.
Nenhuma URL foi inventada para preencher a lacuna.

- Biblioteca Digital da FUNAG (~1.097 títulos, IDs sequenciais)
- Sabatinas de embaixadores (MSF) no Senado
- Discursos de chanceleres e do SG em `gov.br/mre` — acesso profundo devolveu
  "Conteúdo Restrito"

Saíram desta lista em 2026-10-16, por verificação ao vivo: os **Anuários**
(listagem Apache aberta) e os **Relatórios** (listagem desabilitada, mas
enumeráveis pelo Wayback). Ambos estão no manifesto.

Declarada em `FONTES_CDX` mas **ainda sem target no pipeline**: as **notas à
imprensa do MRE**. A fonte está registrada com `verificado_em = NA` justamente
porque a enumeração não foi conferida — ela não entra no manifesto enquanto
não for.

## Situação jurídica — não resolvida

🔴 **O rodapé do portal da FUNAG declara CC BY-ND 3.0.** Uma licença
"SemDerivações" é potencialmente incompatível com a construção de um corpus,
que é obra derivada.

Enquanto isso não estiver resolvido, este repositório:

- **publica** o manifesto, o código de coleta e os metadados;
- **não redistribui** os PDFs de origem.

Três caminhos em aberto, não excludentes:

1. Pedido formal à FUNAG/MRE solicitando licença explícita para uso em pesquisa.
2. O argumento de que atos oficiais, textos de tratados, leis e decisões não são
   obra protegida sob a Lei 9.610/1998. **Requer parecer jurídico — não foi
   confirmado por este projeto.**
3. Manter em definitivo o modelo atual: distribuir código e metadados, e deixar
   que cada pesquisador execute a coleta por conta própria.

## Conduta de coleta

- `User-Agent` identifica projeto, instituição e e-mail de contato.
- Limite de 1 requisição por segundo **por host**.
- Retentativa com espera exponencial; falha vira linha no manifesto, não exceção.
- Acervos do Wayback não recebem sondagem HEAD — o CDX já informa status e
  tamanho, o que evita dezenas de milhares de requisições inúteis.
- Nenhuma tentativa de contornar autenticação, CAPTCHA ou bloqueio de WAF. Fonte
  que exige login fica registrada como bloqueada, e não é coletada.

## Reprodutibilidade

`renv` congela as versões dos pacotes; `targets` registra o grafo de
dependências. `targets::tar_make()` reconstrói o manifesto do zero.
