# Arquitetura & Decisões

## Modelo lógico (simplificado)
```
ORGÃO (sigla PK)
   └─< PESSOA (id_pessoa PK, sigla_orgao FK)
          ├─< ENDERECO (id_endereco PK, id_pessoa FK)
          └─< VINCULO  (id_vinculo PK, id_pessoa FK, matricula UNIQUE)
```

## Fluxo de Orquestração
```
[j01_principal.kjb]
   Start
     ├─> [t01_pessoa.ktr]  -- validações JS, Switch(status), Insert/Update pessoa
     ├─> [t02_orgao.ktr]   -- validações simples, Insert/Update orgao
     ├─> [t03_endereco.ktr]-- validações CEP/UF/numero, Insert/Update endereco
     └─> [t04_vinculo.ktr] -- validações vínculos, Insert/Update vinculo
        \__ On failure -> Abort
        \__ On success -> Success
```

## Padrões adotados
- **Parâmetros** para caminhos e nomes de arquivos (portabilidade).
- **Modified JavaScript Value** para regras de DQ (status/erro).
- **Switch/Case** para separar `OK` e `ERRO`.
- **Insert/Update** para idempotência.
- **Tabelas etl_erros e etl_metricas** para rastreabilidade.
- **Controle de execuções** opcional via `controle_carga`.

## Regras de validação (exemplos)
- **CPF**: 11 dígitos.
- **Data**: formato válido e `< hoje` (nascimento/admissão).
- **Sexo**: `M` ou `F`.
- **UF**: 2 letras.
- **CEP**: 8 dígitos.
- **Situação**: não vazio.

## Observações
- `endereco.numero` é numérico (BIGINT) – se a origem tiver “S/N” ou letras, enviar ao ramo de erro.
- `matricula` marcada como `UNIQUE` para evitar duplicados no vínculo.
