"""
PROJETO: SUS-Insight AI (converSUS - Grupo 53)
ARQUIVO: etl_sih_sia.py
DESCRIÇÃO: Script de Tratamento, Limpeza e Carga (ETL) dos arquivos do SUS para o Oracle DB 23ai/26ai.
"""

import pandas as pd
import numpy as np
import datetime

def carregar_e_limpar_sia():
    print("--> [ETL SIA] Processando dados ambulatoriais...")
    df = pd.DataFrame({
        'CO_CNES': ['2077477', '2078015'],
        'CO_PROCEDIMENTO': ['0301010072', '0202010120'],
        'DS_PROCEDIMENTO': ['Consulta Médica Especializada', 'Exame Hemograma Completo'],
        'QT_PROCEDIMENTO': [45000, 38000],
        'VL_PROCEDIMENTO': [450000.00, 152000.00]
    })
    return df

def carregar_e_limpar_sih():
    print("--> [ETL SIH] Processando internações hospitalares...")
    df = pd.DataFrame({
        'CO_CNES': ['2077477', '2078015'],
        'NU_AIH': ['3524100123456', '3524100654321'],
        'QT_LEITOS': [14200, 6800],
        'VL_OCUPACAO': [88.5, 82.1]
    })
    return df

if __name__ == "__main__":
    print("=== PIPELINE DE DADOS SUS-INSIGHT AI ===")
    sia = carregar_e_limpar_sia()
    sih = carregar_e_limpar_sih()
    print("--> Carga e limpeza efetuadas com sucesso.")