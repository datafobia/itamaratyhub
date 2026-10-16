# itamaratyhub

**Espelhamento defensivo de acervos públicos da política externa brasileira.**
*Defensive mirror of Brazilian foreign policy public archives.*

> **Estágio atual: Fase 0.** Este repositório ainda não é o "hub" de busca —
> é a fundação dele. Hoje ele mantém o **manifesto** dos acervos e o **código
> de coleta**. A camada de corpus, o pacote R e o site de busca vêm depois, e
> provavelmente em repositórios próprios, para que melhorar um classificador
> não obrigue a reemitir o acervo inteiro.

---

## Por que este repositório existe

As fontes primárias digitais da política externa brasileira estão saindo do ar.
Verificado em 16 de outubro de 2026:

| Acervo | Estado |
|---|---|
| Biblioteca da Presidência da República | fora do ar desde cerca de set/2026 |
| Notas à imprensa do MRE | arquivo purgado do site vivo |
| Índices da FUNAG (Resenha, Anuários, Relatórios) | atrás de `require_login`; arquivos ainda públicos no host legado |
| Endpoint MSF do Senado | formalmente desativado |

Este repositório **não** faz análise. Ele faz uma coisa só, e bem: mantém um
**manifesto verificável** do que existe, onde está, quanto pesa e se ainda
responde — e espelha os arquivos enquanto eles existem.

O manifesto é o artefato durável. Versionado em Git porque é pequeno; os bytes
vão para GitHub Releases porque são grandes.

## O manifesto como série temporal

O manifesto é reconstruído semanalmente por GitHub Actions. Cada execução
registra o que respondeu e o que deixou de responder. Acumulado ao longo do
tempo, isso é um **registro longitudinal de mortalidade de fontes públicas** —
e um dado sobre transparência ativa no Executivo brasileiro que hoje ninguém tem.

## Estrutura

```
_targets.R                pipeline (targets)
R/utils.R                 requisição identificada, 1 req/s por host, retry
R/fontes.R                registro de fontes — só URL verificada ao vivo entra
R/listagem_apache.R       enumeração de diretórios Apache abertos (FUNAG)
R/cdx.R                   enumeração via Wayback CDX, com paginação por resumeKey
R/manifesto.R             sondagem HEAD e consolidação
manifesto/manifesto.csv   o artefato
```

## Como rodar

```r
renv::restore()
targets::tar_make()
targets::tar_read(resumo)
```

Resultado da execução de 2026-10-16:

```
      acervo arquivos com_tamanho sem_tamanho   GB          medida vivos_200 mortos_4xx5xx
 presidencia    10130       10122           8 0.98 warc_comprimido     10130             0
     resenha      140         140           0 0.72  content_length       140             0
```

A Fase 0 **não baixa arquivos**. Ela enumera e sonda. Em uma máquina comum leva
poucos minutos e ocupa alguns MB.

## Método de coleta

Toda requisição sai com `User-Agent` identificando o projeto, a instituição e um
e-mail de contato, limitada a **1 requisição por segundo por host**, com
retentativa exponencial. Acervos vindos do Wayback **não** são sondados com
HEAD: o próprio CDX informa status e tamanho, o que evita dezenas de milhares de
requisições desnecessárias.

Nenhuma URL é gerada por fórmula. A nomenclatura dos acervos da FUNAG é
inconsistente (`dec`/`dez`, `1sem`/`1Sem`, duplicatas marcadas `(1)`), então
tudo é enumerado a partir da listagem real.

## Licença

Código sob licença MIT (ver `LICENSE`).

Os documentos espelhados **não** são redistribuídos por este repositório
enquanto a questão de licença dos acervos de origem não estiver resolvida —
ver `PROVENANCE.md`. O que este repositório publica hoje é o **manifesto** e o
**código de coleta**.

## Contato

Dalson Britto Figueiredo Filho — Departamento de Ciência Política, UFPE
`dalson.figueiredofo@ufpe.br`

Se você administra um dos servidores espelhados aqui e quer que a coleta pare,
ajuste o ritmo ou mude de método, escreva para o endereço acima.

---

## English summary

Brazil's primary digital sources on foreign policy are going offline. This
repository keeps a **verifiable manifest** of what exists, where it lives, how
large it is, and whether it still responds — and mirrors the files while they
last. It performs no analysis.

Phase 0 downloads nothing: it enumerates and probes. The manifest is rebuilt
weekly by GitHub Actions, which turns it into a longitudinal record of public
source mortality.

All requests carry an identifying `User-Agent` and are throttled to one request
per second per host. Source documents are not redistributed here pending
clarification of the upstream licences; what is published is the manifest and
the collection code (MIT).
