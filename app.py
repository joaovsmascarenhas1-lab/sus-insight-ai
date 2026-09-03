import os
import streamlit as st
import pandas as pd
import plotly.express as px

# Configuração da Página no Streamlit
st.set_page_config(
    page_title="SUS-Insight AI | converSUS",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Estilização CSS Customizada (Tema Dark & Red - converSUS)
st.markdown("""
<style>
    .stApp {
        background-color: #0b0b0d;
        color: #f4f4f5;
    }
    .main-header {
        font-family: 'Poppins', sans-serif;
        color: #ffffff;
        font-size: 2.2rem;
        font-weight: 700;
        border-left: 6px solid #ef4444;
        padding-left: 15px;
        margin-bottom: 20px;
    }
    .sub-card {
        background-color: #121215;
        border: 1px solid #27272a;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 15px;
    }
    .stButton>button {
        background-color: #ef4444;
        color: white;
        border-radius: 6px;
        border: none;
        font-weight: bold;
    }
    .stButton>button:hover {
        background-color: #dc2626;
        color: white;
    }
</style>
""", unsafe_allow_html=True)

# Título Principal
st.markdown('<div class="main-header">SUS-Insight AI <span style="color:#ef4444; font-size: 1.2rem;">| converSUS (Grupo 53)</span></div>', unsafe_allow_html=True)
st.caption("Plataforma Conversacional de Gestão Estratégica para Dados do SUS (Oracle Autonomous DB 23ai/26ai + OCI Select AI)")

# Barra Lateral - Configurações de Conexão
with st.sidebar:
    st.image("https://img.icons8.com/color/96/oracle-logo.png", width=60)
    st.title("Configurações OCI")
    
    db_user = st.text_input("Usuário Oracle DB", value="ADMIN", type="default")
    db_password = st.text_input("Senha DB", type="password", value="••••••••••••")
    ai_profile = st.selectbox("Perfil Select AI", ["SUS_INSIGHT_PROFILE", "SUS_GLOSAS_PROFILE"])
    
    st.divider()
    st.markdown("### Status da Infraestrutura")
    st.success("🟢 Autonomous DB 26ai: Ativo")
    st.success("🟢 OCI Select AI Engine: Pronto")
    st.info("📊 Mapeamento: SIA, SIH, CNES")
    
    st.divider()
    st.caption("Challenge 2026 - FIAP & Oracle")

# Resposta Simulada para Demonstração Local / Gravação do Pitch
def get_mock_response(query_text):
    query_lower = query_text.lower()
    
    if "leito" in query_lower or "ocupação" in query_lower or "sp" in query_lower:
        sql = """SELECT r.nm_regional AS REGIONAL, 
       SUM(i.qt_leitos_ocupados) AS LEITOS_OCUPADOS,
       ROUND(AVG(i.vl_taxa_ocupacao), 2) AS TAXA_MEDIA_OCUPACAO
FROM TB_SIH_INTERNACOES i
JOIN TB_CNES_ESTABELECIMENTOS e ON i.co_cnes = e.co_cnes
JOIN TB_REGIONAL_SAUDE r ON e.co_regional = r.co_regional
GROUP BY r.nm_regional
ORDER BY LEITOS_OCUPADOS DESC;"""
        df = pd.DataFrame({
            "REGIONAL": ["Grande São Paulo", "Campinas", "Ribeirão Preto", "Baixada Santista", "São José dos Campos"],
            "LEITOS_OCUPADOS": [14200, 6800, 4500, 3900, 3100],
            "TAXA_MEDIA_OCUPACAO": [88.5, 82.1, 79.4, 85.0, 74.2]
        })
        chart_type = "bar"
    elif "glosa" in query_lower or "faturamento" in query_lower or "erro" in query_lower:
        sql = """SELECT g.ds_motivo_glosa AS MOTIVO,
       COUNT(g.id_glosa) AS TOTAL_OCORRENCIAS,
       SUM(g.vl_recusado) AS VALOR_TOTAL_RETIDO
FROM TB_GLOSAS_AUDITORIA g
GROUP BY g.ds_motivo_glosa
ORDER BY VALOR_TOTAL_RETIDO DESC;"""
        df = pd.DataFrame({
            "MOTIVO": ["Divergência CNES/Profissionais", "Incompatibilidade SIGTAP", "Justificativa Médica Ausente", "Inconsistência de Código AIH"],
            "TOTAL_OCORRENCIAS": [1240, 980, 620, 310],
            "VALOR_TOTAL_RETIDO": [450000.00, 310000.00, 180000.00, 75000.00]
        })
        chart_type = "pie"
    else:
        sql = """SELECT p.ds_procedimento AS PROCEDIMENTO, 
       COUNT(p.co_procedimento) AS TOTAL_SOLICITACOES,
       SUM(p.vl_procedimento) AS VALOR_TOTAL
FROM TB_SIA_AMBULATORIAL p
GROUP BY p.ds_procedimento
ORDER BY TOTAL_SOLICITACOES DESC
FETCH FIRST 5 ROWS ONLY;"""
        df = pd.DataFrame({
            "PROCEDIMENTO": ["Consulta Médica Especializada", "Exame de Hemograma Completo", "Tomografia Computadorizada", "Atendimento de Urgência", "Ultrassonografia Abdominal"],
            "TOTAL_SOLICITACOES": [45000, 38000, 12000, 29000, 15000],
            "VALOR_TOTAL": [450000.00, 152000.00, 1032000.00, 580000.00, 360000.00]
        })
        chart_type = "bar"
        
    return sql, df, chart_type

# Interface de Chat Conversacional
st.markdown("### 💬 Pergunte aos Dados do SUS")

if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "Olá, Gestor! Sou o **SUS-Insight AI**. Como posso ajudar na análise de dados do SUS hoje? Tente perguntar: *'Qual a taxa de ocupação de leitos por regional em SP?'* ou *'Quais os principais motivos de glosas de faturamento?'*"}
    ]

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if user_prompt := st.chat_input("Digite sua pergunta em português..."):
    st.session_state.messages.append({"role": "user", "content": user_prompt})
    with st.chat_message("user"):
        st.markdown(user_prompt)

    with st.chat_message("assistant"):
        with st.spinner("🤖 Oracle Select AI interpretando linguagem natural e consultando o Autonomous DB 26ai..."):
            generated_sql, df_result, chart_type = get_mock_response(user_prompt)
            
            response_text = f"Análise concluída com sucesso! Resultados extraídos da base do SUS via perfil **{ai_profile}**:"
            st.markdown(response_text)
            
            with st.expander("🛠️ Ver SQL Automático Gerado pelo Oracle Select AI", expanded=False):
                st.code(generated_sql, language="sql")
            
            st.markdown("#### 📋 Dados Retornados")
            st.dataframe(df_result, use_container_width=True)
            
            st.markdown("#### 📊 Visualização de Insight")
            if chart_type == "bar":
                fig = px.bar(
                    df_result, 
                    x=df_result.columns[0], 
                    y=df_result.columns[1],
                    color=df_result.columns[0],
                    color_discrete_sequence=px.colors.qualitative.Bold,
                    title=f"Distribuição por {df_result.columns[0]}"
                )
            else:
                fig = px.pie(
                    df_result, 
                    names=df_result.columns[0], 
                    values=df_result.columns[2],
                    title=f"Proporção de Valor por {df_result.columns[0]}",
                    color_discrete_sequence=px.colors.sequential.RdBu
                )
            
            fig.update_layout(
                paper_bgcolor="rgba(0,0,0,0)",
                plot_bgcolor="rgba(0,0,0,0)",
                font_color="#ffffff"
            )
            st.plotly_chart(fig, use_container_width=True)

    st.session_state.messages.append({"role": "assistant", "content": response_text})