CREATE TABLE public.orgao (
  sigla_orgao VARCHAR(20) PRIMARY KEY,
  servidores_qty INTEGER NOT NULL,
  dt_cadastro TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE public.pessoa (
  id_pessoa BIGINT PRIMARY KEY,
  nome_completo TEXT NOT NULL,
  cpf CHAR(11) NOT NULL,
  data_nascimento DATE NOT NULL,
  sexo CHAR(1) NOT NULL,
  sigla_orgao VARCHAR(20) NOT NULL,
  dt_cadastro TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_pessoa_cpf UNIQUE (cpf)
);

CREATE TABLE public.endereco (
  id_endereco BIGSERIAL PRIMARY KEY,
  id_pessoa BIGINT NOT NULL,
  logradouro TEXT NOT NULL,
  numero INTEGER,
  bairro TEXT,
  cidade TEXT,
  uf CHAR(2),
  cep VARCHAR(8),
  dt_cadastro TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TABLE public.metricas (
  id_metricas BIGSERIAL PRIMARY KEY,
  data_execucao TIMESTAMP NOT NULL DEFAULT NOW(),
  nome_etapa TEXT NOT NULL,
  linhas_lidas INTEGER NOT NULL DEFAULT 0,
  linhas_gravadas INTEGER NOT NULL DEFAULT 0,
  linhas_erro INTEGER NOT NULL DEFAULT 0,
  arquivo_origem TEXT
);

CREATE TABLE public.etl_erros (
  id_erro BIGSERIAL PRIMARY KEY,
  data_execucao TIMESTAMP NOT NULL DEFAULT NOW(),
  nome_etapa TEXT,
  linha_num INTEGER,
  arquivo_origem TEXT,
  motivo TEXT,
  payload JSONB
);

