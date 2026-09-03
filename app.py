import os
import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(page_title="SUS-Insight AI | converSUS", page_icon="🏥", layout="wide")

# CSS personalizado para correção de cores e contraste
st.markdown("""
<style>
    /* 1. Fundo escuro e texto global 100% branco */
    .stApp, .stAppViewContainer {
        background-color: #0e1117 !important;
        color: #ffffff !important;
    }
    
    p, span, div, label, h1, h2, h3, h4, h5, h6, .stMarkdown, .stCaption {
        color: #ffffff !important;
    }
    
    /* 2. Caixa de Pergunta (Fundo Branco + Texto Preto) */
    div[data-baseweb="input"] input, 
    .stChatInput textarea,
    textarea {
        color: #000000 !important;
        background-color: #ffffff !important;
        -webkit-text-fill-color: #000000 !important;
        font-weight: 500 !important;
    }
    
    div[data-baseweb="input"] input::placeholder,
    .stChatInput textarea::placeholder {
        color: #555555 !important;
        -webkit-text-fill-color: #555555 !important;
    }
    
    /* Barra lateral */
    [data-testid="stSidebar"] {
        background-color: #1a1f2c !important;
    }
    [data-testid="stSidebar"] * {
        color: #ffffff !important;
    }
</style>
""", unsafe_allow_html=True)

st.markdown("<h1 style='color: #ef4444;'>SUS-Insight AI | converSUS </h1>", unsafe_allow_html=True)
st.caption("Plataforma Conversacional de Gestão Estratégica para Dados do SUS (Oracle Autonomous DB + OCI Select AI)")

with st.sidebar:
    st.title("Configurações OCI")
    st.text_input("Usuário Oracle DB", value="ADMIN", disabled=True)
    st.selectbox("Perfil Select AI", ["SUS_INSIGHT_PROFILE"])
    st.success("🟢 Autonomous DB 26ai: Ativo")
    st.success("🟢 OCI Select AI Engine: Pronto")
    st.info("📊 Mapeamento: SIA, SIH, CNES")

# Dados para visualização analítica
mock_df = pd.DataFrame({
    'REGIONAL': ['Grande São Paulo', 'Campinas', 'Ribeirão Preto', 'Baixada Santista', 'São José dos Campos'],
    'LEITOS_OCUPADOS': [14200, 6800, 4500, 3900, 3100],
    'TAXA_MEDIA_OCUPACAO': [88.5, 82.1, 79.4, 85.0, 74.2]
})

st.markdown("### 💬 Pergunte aos Dados do SUS")
prompt = st.chat_input("Digite sua pergunta em português (ex: Qual a taxa de ocupação de leitos por regional em SP?)...")

if prompt:
    # Mensagem do Usuário
    with st.chat_message("user"):
        st.write(prompt)
    
    # Resposta da IA e visualizações
    with st.chat_message("assistant"):
        st.write("Análise concluída com sucesso! Resultados extraídos da base do SUS via perfil `SUS_INSIGHT_PROFILE`:")
        
        # Caixa de Auditoria SQL (Select AI)
        with st.expander(" Ver SQL Automático Gerado pelo Oracle Select AI"):
            sql_code = """SELECT r.nm_regional AS REGIONAL,
       SUM(i.qt_leitos_ocupados) AS LEITOS_OCUPADOS,
       ROUND(AVG(i.vl_taxa_ocupacao), 2) AS TAXA_MEDIA_OCUPACAO
FROM TB_SIH_INTERNACOES i
JOIN TB_CNES_ESTABELECIMENTOS e ON i.co_cnes = e.co_cnes
JOIN TB_REGIONAL_SAUDE r ON e.co_regional = r.co_regional
GROUP BY r.nm_regional
ORDER BY LEITOS_OCUPADOS DESC;"""
            st.code(sql_code, language="sql")
        
        # Tabela de Dados Retornados
        st.markdown("#### 📋 Dados Retornados")
        st.dataframe(mock_df, use_container_width=True)
        
        # Gráfico Dinâmico Plotly
        st.markdown("#### 📊 Visualização de Insight")
        fig = px.bar(
            mock_df, 
            x='REGIONAL', 
            y='LEITOS_OCUPADOS', 
            color='REGIONAL',
            title='Distribuição de Leitos Ocupados por REGIONAL',
            labels={'LEITOS_OCUPADOS': 'Leitos Ocupados', 'REGIONAL': 'Regional de Saúde'}
        )
        fig.update_layout(
            template="plotly_dark",
            paper_bgcolor="#0e1117",
            plot_bgcolor="#0e1117"
        )
        st.plotly_chart(fig, use_container_width=True)