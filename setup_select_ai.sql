-- =============================================================================
-- PROJETO: SUS-Insight AI (converSUS - Grupo 53 | Turma 1TSCO)
-- AMBIENTE: Oracle Autonomous Database 23ai / 26ai (OCI Cloud)
-- DESCRIÇÃO: DDL, DML, Comentários Semânticos e Perfil OCI Select AI
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. LIMPEZA PREVENTIVA DE TABELAS (SE JÁ EXISTIREM)
-- -----------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_GLOSAS_AUDITORIA CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE TB_SIH_INTERNACOES CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE TB_SIA_AMBULATORIAL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE TB_CNES_ESTABELECIMENTOS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE TB_REGIONAL_SAUDE CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- -----------------------------------------------------------------------------
-- 2. CRIAÇÃO DAS TABELAS RELACIONAIS (SIA, SIH, CNES E REGIONAIS)
-- -----------------------------------------------------------------------------

-- Tabela de Regionais de Saúde
CREATE TABLE TB_REGIONAL_SAUDE (
    co_regional VARCHAR2(10) PRIMARY KEY,
    nm_regional VARCHAR2(100) NOT NULL,
    uf VARCHAR2(2) DEFAULT 'SP' NOT NULL
);

-- Tabela de Estabelecimentos de Saúde (CNES)
CREATE TABLE TB_CNES_ESTABELECIMENTOS (
    co_cnes VARCHAR2(10) PRIMARY KEY,
    no_estabelecimento VARCHAR2(150) NOT NULL,
    co_regional VARCHAR2(10) REFERENCES TB_REGIONAL_SAUDE(co_regional),
    tp_unidade VARCHAR2(50),
    qt_leitos_total NUMBER(5) DEFAULT 0,
    dt_atualizacao DATE DEFAULT SYSDATE
);

-- Tabela de Atendimentos Ambulatoriais (SIA/APAC)
CREATE TABLE TB_SIA_AMBULATORIAL (
    id_atendimento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    co_cnes VARCHAR2(10) REFERENCES TB_CNES_ESTABELECIMENTOS(co_cnes),
    co_procedimento VARCHAR2(10) NOT NULL,
    ds_procedimento VARCHAR2(200) NOT NULL,
    qt_procedimento NUMBER(10) DEFAULT 1,
    vl_procedimento NUMBER(12,2) DEFAULT 0.00,
    dt_atendimento DATE DEFAULT SYSDATE,
    st_faturamento VARCHAR2(20) DEFAULT 'APROVADO'
);

-- Tabela de Internações Hospitalares (SIH/AIH)
CREATE TABLE TB_SIH_INTERNACOES (
    id_internacao NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    co_cnes VARCHAR2(10) REFERENCES TB_CNES_ESTABELECIMENTOS(co_cnes),
    nu_aih VARCHAR2(20) NOT NULL,
    dt_internacao DATE,
    dt_alta DATE,
    qt_leitos_ocupados NUMBER(5) DEFAULT 1,
    vl_taxa_ocupacao NUMBER(5,2),
    vl_total_aih NUMBER(12,2) DEFAULT 0.00,
    st_aih VARCHAR2(30) DEFAULT 'PROCESSADO'
);

-- Tabela de Glosas de Faturamento e Auditorias
CREATE TABLE TB_GLOSAS_AUDITORIA (
    id_glosa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nu_aih VARCHAR2(20),
    co_cnes VARCHAR2(10) REFERENCES TB_CNES_ESTABELECIMENTOS(co_cnes),
    ds_motivo_glosa VARCHAR2(250) NOT NULL,
    ds_parecer_auditor VARCHAR2(1000),
    vl_recusado NUMBER(12,2) DEFAULT 0.00,
    dt_glosa DATE DEFAULT SYSDATE
);

-- -----------------------------------------------------------------------------
-- 3. ENRIQUECIMENTO SEMÂNTICO (COMENTÁRIOS DE TABELA E COLUNA PARA SELECT AI)
-- O Oracle Select AI utiliza esses comentários para entender a regra de negócio!
-- -----------------------------------------------------------------------------
COMMENT ON TABLE TB_REGIONAL_SAUDE IS 'Tabela que armazena as Regionais de Saúde e Divisões Regionais do SUS no Estado de São Paulo.';
COMMENT ON COLUMN TB_REGIONAL_SAUDE.nm_regional IS 'Nome da regional de saude (Ex: Grande Sao Paulo, Campinas, Ribeirao Preto, Baixada Santista).';

COMMENT ON TABLE TB_CNES_ESTABELECIMENTOS IS 'Cadastro Nacional de Estabelecimentos de Saude (CNES) contendo hospitais, UPA e postos de saude.';
COMMENT ON COLUMN TB_CNES_ESTABELECIMENTOS.no_estabelecimento IS 'Nome fantasia ou razao social do hospital ou unidade de saude.';

COMMENT ON TABLE TB_SIH_INTERNACOES IS 'Sistema de Informacoes Hospitalares (SIH) com dados de autorizacoes de internacao hospitalar (AIH).';
COMMENT ON COLUMN TB_SIH_INTERNACOES.qt_leitos_ocupados IS 'Quantidade de leitos de UTI ou enfermaria ocupados durante o periodo.';
COMMENT ON COLUMN TB_SIH_INTERNACOES.vl_taxa_ocupacao IS 'Percentual da taxa de ocupacao de leitos no hospital (0 a 100%).';

COMMENT ON TABLE TB_GLOSAS_AUDITORIA IS 'Registros de glosas operacionais, recusadas pelo SUS por inconformidades no faturamento de AIH/SIA.';
COMMENT ON COLUMN TB_GLOSAS_AUDITORIA.ds_motivo_glosa IS 'Motivo da recusa financeira (Ex: Divergencia CNES, Incompatibilidade SIGTAP, Erro de Codigo).';
COMMENT ON COLUMN TB_GLOSAS_AUDITORIA.vl_recusado IS 'Valor financeiro em reais (R$) retido ou recusado pela auditoria.';

-- -----------------------------------------------------------------------------
-- 4. INSERÇÃO DE DADOS DE EXEMPLO (SÃO PAULO)
-- -----------------------------------------------------------------------------

-- Regionais
INSERT INTO TB_REGIONAL_SAUDE (co_regional, nm_regional, uf) VALUES ('REG01', 'Grande São Paulo', 'SP');
INSERT INTO TB_REGIONAL_SAUDE (co_regional, nm_regional, uf) VALUES ('REG02', 'Campinas', 'SP');
INSERT INTO TB_REGIONAL_SAUDE (co_regional, nm_regional, uf) VALUES ('REG03', 'Ribeirão Preto', 'SP');
INSERT INTO TB_REGIONAL_SAUDE (co_regional, nm_regional, uf) VALUES ('REG04', 'Baixada Santista', 'SP');
INSERT INTO TB_REGIONAL_SAUDE (co_regional, nm_regional, uf) VALUES ('REG05', 'São José dos Campos', 'SP');

-- Estabelecimentos (CNES)
INSERT INTO TB_CNES_ESTABELECIMENTOS (co_cnes, no_estabelecimento, co_regional, tp_unidade, qt_leitos_total)
VALUES ('2077477', 'HOSPITAL DAS CLINICAS DA USP - SP', 'REG01', 'HOSPITAL GERAL', 1200);

INSERT INTO TB_CNES_ESTABELECIMENTOS (co_cnes, no_estabelecimento, co_regional, tp_unidade, qt_leitos_total)
VALUES ('2078015', 'HOSPITAL E MATERNIDADE CELSO PIERRO - CAMPINAS', 'REG02', 'HOSPITAL GERAL', 450);

INSERT INTO TB_CNES_ESTABELECIMENTOS (co_cnes, no_estabelecimento, co_regional, tp_unidade, qt_leitos_total)
VALUES ('2080112', 'HOSPITAL DAS CLINICAS DE RIBEIRAO PRETO', 'REG03', 'HOSPITAL UNIVERSITARIO', 800);

-- Internações (SIH)
INSERT INTO TB_SIH_INTERNACOES (co_cnes, nu_aih, dt_internacao, dt_alta, qt_leitos_ocupados, vl_taxa_ocupacao, vl_total_aih)
VALUES ('2077477', '3524100123456', SYSDATE-15, SYSDATE, 14200, 88.50, 1250000.00);

INSERT INTO TB_SIH_INTERNACOES (co_cnes, nu_aih, dt_internacao, dt_alta, qt_leitos_ocupados, vl_taxa_ocupacao, vl_total_aih)
VALUES ('2078015', '3524100654321', SYSDATE-10, SYSDATE, 6800, 82.10, 540000.00);

INSERT INTO TB_SIH_INTERNACOES (co_cnes, nu_aih, dt_internacao, dt_alta, qt_leitos_ocupados, vl_taxa_ocupacao, vl_total_aih)
VALUES ('2080112', '3524100987654', SYSDATE-12, SYSDATE, 4500, 79.40, 410000.00);

-- Atendimentos Ambulatoriais (SIA)
INSERT INTO TB_SIA_AMBULATORIAL (co_cnes, co_procedimento, ds_procedimento, qt_procedimento, vl_procedimento)
VALUES ('2077477', '0301010072', 'Consulta Médica em Atenção Especializada', 45000, 450000.00);

INSERT INTO TB_SIA_AMBULATORIAL (co_cnes, co_procedimento, ds_procedimento, qt_procedimento, vl_procedimento)
VALUES ('2077477', '0202010120', 'Exame de Hemograma Completo', 38000, 152000.00);

INSERT INTO TB_SIA_AMBULATORIAL (co_cnes, co_procedimento, ds_procedimento, qt_procedimento, vl_procedimento)
VALUES ('2078015', '0206010079', 'Tomografia Computadorizada de Tórax', 12000, 1032000.00);

-- Glosas e Auditoria
INSERT INTO TB_GLOSAS_AUDITORIA (nu_aih, co_cnes, ds_motivo_glosa, ds_parecer_auditor, vl_recusado)
VALUES ('3524100123456', '2077477', 'Divergência CNES/Profissionais', 'A escala médica cadastrada no CNES difere do plantonista assinado na alta.', 450000.00);

INSERT INTO TB_GLOSAS_AUDITORIA (nu_aih, co_cnes, ds_motivo_glosa, ds_parecer_auditor, vl_recusado)
VALUES ('3524100654321', '2078015', 'Incompatibilidade SIGTAP', 'Procedimento cobrado incompativel com o CID principal de internacao.', 310000.00);

INSERT INTO TB_GLOSAS_AUDITORIA (nu_aih, co_cnes, ds_motivo_glosa, ds_parecer_auditor, vl_recusado)
VALUES ('3524100987654', '2080112', 'Justificativa Médica Ausente', 'Ausência de laudo de imagem para autorização de AIH especial.', 180000.00);

COMMIT;

-- -----------------------------------------------------------------------------
-- 5. CONFIGURAÇÃO DA CREDENCIAL OCI GENERATIVE AI
-- -----------------------------------------------------------------------------
BEGIN
  BEGIN DBMS_CLOUD.DROP_CREDENTIAL(credential_name => 'OCI_GENAI_CRED'); EXCEPTION WHEN OTHERS THEN NULL; END;

  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'OCI_GENAI_CRED',
    user_ocid       => 'ocid1.user.oc1..exampleuserocid',
    tenancy_ocid    => 'ocid1.tenancy.oc1..exampletenancyocid',
    private_key     => '-----BEGIN RSA PRIVATE KEY----- ... -----END RSA PRIVATE KEY-----',
    fingerprint     => '20:3b:97:10:55:00:11:22:33:44:55:66:77:88:99:00'
  );
END;
/

-- -----------------------------------------------------------------------------
-- 6. CRIAÇÃO DO PERFIL ORACLE SELECT AI (AI VECTOR SEARCH + NL2SQL)
-- -----------------------------------------------------------------------------
BEGIN
  BEGIN DBMS_CLOUD_AI.DROP_PROFILE(profile_name => 'SUS_INSIGHT_PROFILE'); EXCEPTION WHEN OTHERS THEN NULL; END;

  DBMS_CLOUD_AI.CREATE_PROFILE(
    profile_name => 'SUS_INSIGHT_PROFILE',
    attributes   => '{"provider": "oci",
                      "credential_name": "OCI_GENAI_CRED",
                      "object_list": [
                        {"owner": "ADMIN", "name": "TB_REGIONAL_SAUDE"},
                        {"owner": "ADMIN", "name": "TB_CNES_ESTABELECIMENTOS"},
                        {"owner": "ADMIN", "name": "TB_SIA_AMBULATORIAL"},
                        {"owner": "ADMIN", "name": "TB_SIH_INTERNACOES"},
                        {"owner": "ADMIN", "name": "TB_GLOSAS_AUDITORIA"}
                      ],
                      "comments": "Perfil de Inteligencia Artificial para converter perguntas em portugues em instrucoes SQL sobre faturamento e leitos do SUS."
                     }'
  );
END;
/

-- -----------------------------------------------------------------------------
-- 7. ATIVAÇÃO DO PERFIL E TESTE DE CONSULTAS
-- -----------------------------------------------------------------------------
EXEC DBMS_CLOUD_AI.SET_PROFILE('SUS_INSIGHT_PROFILE');

SELECT * FROM TB_CNES_ESTABELECIMENTOS;
SELECT * FROM TB_SIH_INTERNACOES;
SELECT * FROM TB_GLOSAS_AUDITORIA;