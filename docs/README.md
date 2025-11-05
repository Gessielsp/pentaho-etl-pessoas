# ETL – Teste Analista de Dados (Pentaho + PostgreSQL)

> Autor: Gessiel Silva Passos

Este repositório contém uma solução de ETL completa usando **Pentaho Data Integration (PDI/Spoon)** e **PostgreSQL** para integrar dados de pessoas, órgãos, endereços e vínculos, com **validações de qualidade**, **relatório de erros**, **métricas de execução**, **idempotência** (reprocessamento sem duplicidade) e **job de orquestração**.

## 📦 Conteúdo
```
/docs
  README.md           ← este arquivo
  ARQUITETURA.md      ← desenho lógico, decisões e fluxos
/sql
  01_ddl.sql          ← criação das tabelas destino + apoio
/kettle
  j01_principal.kjb   ← job principal (orquestra as 4 transformações)
  t01_pessoa.ktr
  t02_orgao.ktr
  t03_endereco.ktr
  t04_vinculo.ktr
/input
  pessoas.csv
  orgaos.csv
  enderecos.csv
  vinculos.csv
/logs                  ← destino dos logs (csv + kitchen)
```

> **Observação**: os arquivos *.ktr/*.kjb não estão versionados aqui; devem ser salvos pelo Spoon nesse caminho `kettle/` com os nomes acima. Os CSVs de exemplo devem ser colocados em `/input`.

## 🗄️ Banco de Dados
Execute o script de DDL antes de rodar o ETL:
```bash
psql -h <host> -U <user> -d <db> -f sql/01_ddl.sql
```

## ⚙️ Parâmetros (usar no Spoon e no Kitchen)
- `P_INPUT_DIR` → caminho dos arquivos de entrada (ex.: `C:\Pentaho\ETL_PESSOAS_PENTAHO\dados_entrada` ou `<repo>/input`)
- `P_LOG_DIR` → caminho de logs (ex.: `C:\Pentaho\ETL_PESSOAS_PENTAHO\logs` ou `<repo>/logs`)
- `ARQ_PESSOAS` → `pessoas.csv`
- `ARQ_ORGAOS` → `orgaos.csv`
- `ARQ_ENDERECOS` → `enderecos.csv`
- `ARQ_VINCULOS` → `vinculos.csv`

Nos passos *CSV Input* referencie `${P_INPUT_DIR}/${ARQ_*}` e nos *Text File Output* de erros `${P_LOG_DIR}/erros_<tabela>.csv`.

## 🚦 Ordem de execução
1. `t01_pessoa.ktr`  
2. `t02_orgao.ktr`  
3. `t03_endereco.ktr`  
4. `t04_vinculo.ktr`  

> Ligue em sequência no `j01_principal.kjb` com **On Success**. Opcional: **Abort** em **On Failure**.

## ▶️ Executando no Spoon
- Abra o **j01_principal.kjb**
- Em cada *Job → Transformation*, marque **Pass parameters to transformation**
- Defina os parâmetros no Job (menu **Edit → Settings → Parameters**)
- Rode o Job e verifique os *Step Metrics* e o console

## 🖥️ Executando em linha de comando (Kitchen)
Windows:
```bat
Kitchen.bat -file:"C:\caminho\para\kettle\j01_principal.kjb" -level=Basic ^
  -param:P_INPUT_DIR="C:\Pentaho\ETL_PESSOAS_PENTAHO\dados_entrada" ^
  -param:P_LOG_DIR="C:\Pentaho\ETL_PESSOAS_PENTAHO\logs" ^
  -param:ARQ_PESSOAS="pessoas.csv" ^
  -param:ARQ_ORGAOS="orgaos.csv" ^
  -param:ARQ_ENDERECOS="enderecos.csv" ^
  -param:ARQ_VINCULOS="vinculos.csv" ^
  -logfile "C:\Pentaho\ETL_PESSOAS_PENTAHO\logs\job_%Y-%m-%d_%H%M%S.log"
```

Linux:
```bash
./kitchen.sh -file="/caminho/para/kettle/j01_principal.kjb" -level=Basic   -param:P_INPUT_DIR="/dados/entrada"   -param:P_LOG_DIR="/logs"   -param:ARQ_PESSOAS="pessoas.csv"   -param:ARQ_ORGAOS="orgaos.csv"   -param:ARQ_ENDERECOS="enderecos.csv"   -param:ARQ_VINCULOS="vinculos.csv"   -logfile "/logs/job_%Y-%m-%d_%H%M%S.log"
```

## ✅ O que esta solução cobre
- **Normalização** em tabelas relacionais
- **Integridade** com PK, FK, UNIQUE conforme aplicável
- **Padronização** e validação de dados (JS no *Modified JavaScript Value*)
- **Relatório de erros** em CSV (`/logs`) e tabela `etl_erros`
- **Métricas** por execução na tabela `etl_metricas`
- **Idempotência** (Insert/Update) e **retomada** segura

## 🔍 Checks rápidos
```sql
-- 1) Rodar 2x e não duplicar
SELECT COUNT(*) FROM pessoa;
SELECT COUNT(*) FROM orgao;
SELECT COUNT(*) FROM endereco;
SELECT COUNT(*) FROM vinculo;

-- 2) Integridade referencial
SELECT p.* FROM pessoa p
LEFT JOIN orgao o ON o.sigla = p.sigla_orgao
WHERE o.sigla IS NULL AND p.sigla_orgao IS NOT NULL;

SELECT e.* FROM endereco e
LEFT JOIN pessoa p ON p.id_pessoa = e.id_pessoa
WHERE p.id_pessoa IS NULL;

SELECT v.* FROM vinculo v
LEFT JOIN pessoa p ON p.id_pessoa = v.id_pessoa
WHERE p.id_pessoa IS NULL;

-- 3) Métricas
SELECT * FROM etl_metricas ORDER BY data_execucao DESC LIMIT 10;

-- 4) Erros
SELECT * FROM etl_erros ORDER BY ts_erro DESC LIMIT 10;
```

## 🧩 Dúvidas comuns
- **“Não vejo o .ktr no seletor do Job”** → confira a aba **General** do *Job Entry → Transformation* e troque para **“Specify by filename”**, apontando para o caminho absoluto do `.ktr`.
- **“Kitchen diz que não achou parâmetros”** → defina no **Job (nível do Job)** e marque **Pass parameters to transformation** em cada Job Entry.
---

**Boa sorte na apresentação!** Mostre o `j01_principal.kjb` rodando, as métricas preenchidas e os relatórios de erro. 
