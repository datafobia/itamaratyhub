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
| Wayback CDX, `biblioteca.presidencia.gov.br` | ativo; **mais de 60.000 URLs únicas**, das quais **ao menos 10.310** sob `/discursos/` |
| Wayback CDX, `bibliotecas.presidencia.gov.br` | **zero capturas** |

## Primeiro manifesto — medido, não estimado

Execução de 2026-10-16, `targets::tar_make()`:

| Acervo | Arquivos | Vivos (200) | Mortos (4xx/5xx) | Tamanho | Medida |
|---|---|---|---|---|---|
| `resenha` | 140 | 140 | 0 | **0,72 GB** | `Content-Length` |
| `presidencia` | 10.130 | 10.130 | 0 | 0,98 GB | registro WARC comprimido |

Observações que mudam o planejamento:

- **A Resenha tem 140 arquivos, dos quais 16 são duplicatas `(1)`** — logo, cerca
  de 124 edições únicas, o que reconcilia com a contagem de edições registrada
  na literatura. A confirmação definitiva exige comparar SHA-256 após o download.
- **Os dois acervos verificados somam ~1,7 GB, não 13 GB.** A estimativa de 13 GB
  depende inteiramente dos Anuários (~4,85 GB) e dos Relatórios (~7,3 GB), que
  continuam **não verificados** e sem URL confirmada. Até que sejam, o espelho
  cabe folgado em qualquer máquina.
- Para `presidencia`, 8 de 10.130 registros vinham com `length` impossível
  (até −10.485.042.932) e agora entram como `NA`. Ver `sanear_length()`.
- Nenhuma URL morta nos dois acervos nesta execução. O valor do manifesto
  semanal é justamente detectar quando isso mudar.

### Duas correções a relatórios anteriores

1. **O host da Biblioteca da Presidência é `biblioteca`, no singular.** A grafia
   no plural, que constava do levantamento inicial, não tem nenhuma captura no
   Wayback. O volume também é maior do que o estimado: mais de 60.000 URLs
   únicas contra 25.819, e ao menos 10.310 sob `/discursos/` contra 8.677.
   O número real é maior ainda — 60.000 foi o teto da consulta exploratória.

2. **O diretório `/Resenhas/Novas/` tem 64 PDFs, não 61.** Diferença pequena,
   mas ilustra a razão de enumerar a listagem em vez de confiar em contagem
   registrada: o acervo muda.

## Fontes ainda não verificadas

Listadas em `R/fontes.R`, em `FONTES_PENDENTES`, **sem URL**. Elas aparecem em
levantamentos com volumes estimados, mas os caminhos não foram confirmados.
Nenhuma URL foi inventada para preencher a lacuna.

- Anuários/Almanaques do Pessoal do MRE, 1916–2010
- Relatórios do MRE, 1830–1960
- Biblioteca Digital da FUNAG
- Sabatinas de embaixadores (MSF) no Senado

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
